# frozen_string_literal: true

# Queues the workflow execution submission job
class WorkflowExecutionPreparationJob < ApplicationJob
  queue_as :default

  def perform(workflow_execution)
    return if workflow_execution.canceling? || workflow_execution.canceled?

    result = WorkflowExecutions::PreparationService.new(workflow_execution).execute

    if result
      WorkflowExecutionSubmissionJob.set(wait_until: 30.seconds.from_now).perform_later(workflow_execution)
    else
      @workflow_execution.state = :error
      @workflow_execution.cleaned = true
      @workflow_execution.save
    end
  end
end
