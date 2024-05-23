# frozen_string_literal: true

require 'test_helper'

class IntegrationSapporo < ActiveSupport::TestCase
  def setup
    @workflow_execution = workflow_executions(:irida_next_example_end_to_end)
  end

  test 'integration sapporo end to end' do
    assert_equal 'initial', @workflow_execution.state
    assert_not @workflow_execution.cleaned?

    WorkflowExecutionPreparationJob.perform_later(@workflow_execution)

    perform_enqueued_jobs_sequentially(except: WorkflowExecutionSubmissionJob)
    assert_equal 'prepared', @workflow_execution.reload.state

    perform_enqueued_jobs_sequentially(except: WorkflowExecutionStatusJob)
    assert_equal 'submitted', @workflow_execution.reload.state

    perform_enqueued_jobs_sequentially(delay_seconds: 10, except: WorkflowExecutionCompletionJob)
    assert_equal 'completing', @workflow_execution.reload.state

    perform_enqueued_jobs_sequentially(except: WorkflowExecutionCleanupJob)
    assert_equal 'completed', @workflow_execution.reload.state

    perform_enqueued_jobs_sequentially
    assert_equal 'completed', @workflow_execution.reload.state
    assert @workflow_execution.cleaned?
  end

  private

  # Jobs that are retried must be run one at a time with a short delay to prevent stack errors
  # Allows use of only/except to exit early like perform_enqueued_jobs does
  def perform_enqueued_jobs_sequentially(delay_seconds: 1, only: nil, except: nil) # rubocop:disable Metrics/AbcSize
    class_filter = lambda { |job_class|
      (only.nil? || job_class == only.name) &&
        (except.nil? || job_class != except.name)
    }

    while enqueued_jobs.count >= 1 && class_filter.call(enqueued_jobs.first['job_class'])
      perform_enqueued_jobs(
        only: ->(job) { job['job_id'] == enqueued_jobs.first['job_id'] }
      )
      sleep(delay_seconds)
    end
  end
end
