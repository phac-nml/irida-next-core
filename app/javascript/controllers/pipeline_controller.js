import { Controller } from "@hotwired/stimulus";

const SCHEMA = {
  $schema: "http://json-schema.org/draft-07/schema",
  $id: "https://raw.githubusercontent.com/nf-core/testpipeline/master/nextflow_schema.json",
  title: "nf-core/testpipeline pipeline parameters",
  description: "this is a test",
  type: "object",
  definitions: {
    input_output_options: {
      title: "Input/output options",
      type: "object",
      fa_icon: "fas fa-terminal",
      description:
        "Define where the pipeline should find input data and save output data.",
      required: ["input", "outdir"],
      properties: {
        input: {
          type: "string",
          format: "file-path",
          mimetype: "text/csv",
          pattern: "^\\S+\\.(csv|tsv|yaml)$",
          description:
            "Path to comma-separated file containing information about the samples in the experiment.",
          help_text:
            "You will need to create a design file with information about the samples in your experiment before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row. See [usage docs](https://nf-co.re/testpipeline/usage#samplesheet-input).",
          fa_icon: "fas fa-file-csv",
        },
        outdir: {
          type: "string",
          format: "directory-path",
          description:
            "The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.",
          fa_icon: "fas fa-folder-open",
        },
        email: {
          type: "string",
          description: "Email address for completion summary.",
          fa_icon: "fas fa-envelope",
          help_text:
            "Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If set in your user config file (`~/.nextflow/config`) then you don't need to specify this on the command line for every run.",
          pattern:
            "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$",
        },
        multiqc_title: {
          type: "string",
          description:
            "MultiQC report title. Printed as page header, used for filename if not otherwise specified.",
          fa_icon: "fas fa-file-signature",
        },
      },
    },
    reference_genome_options: {
      title: "Reference genome options",
      type: "object",
      fa_icon: "fas fa-dna",
      description:
        "Reference genome related files and options required for the workflow.",
      properties: {
        genome: {
          type: "string",
          description: "Name of iGenomes reference.",
          fa_icon: "fas fa-book",
          help_text:
            "If using a reference genome configured in the pipeline using iGenomes, use this parameter to give the ID for the reference. This is then used to build the full paths for all required reference genome files e.g. `--genome GRCh38`. \n\nSee the [nf-core website docs](https://nf-co.re/usage/reference_genomes) for more details.",
        },
        fasta: {
          type: "string",
          format: "file-path",
          mimetype: "text/plain",
          pattern: "^\\S+\\.fn?a(sta)?(\\.gz)?$",
          description: "Path to FASTA genome file.",
          help_text:
            "This parameter is *mandatory* if `--genome` is not specified. If you don't have a BWA index available this will be generated for you automatically. Combine with `--save_reference` to save BWA index for future runs.",
          fa_icon: "far fa-file-code",
        },
        igenomes_base: {
          type: "string",
          format: "directory-path",
          description: "Directory / URL base for iGenomes references.",
          default: "s3://ngi-igenomes/igenomes",
          fa_icon: "fas fa-cloud-download-alt",
          hidden: true,
        },
        igenomes_ignore: {
          type: "boolean",
          description: "Do not load the iGenomes reference config.",
          fa_icon: "fas fa-ban",
          hidden: true,
          help_text:
            "Do not load `igenomes.config` when running the pipeline. You may choose this option if you observe clashes between custom parameters and those supplied in `igenomes.config`.",
        },
      },
    },
    institutional_config_options: {
      title: "Institutional config options",
      type: "object",
      fa_icon: "fas fa-university",
      description:
        "Parameters used to describe centralised config profiles. These should not be edited.",
      help_text:
        "The centralised nf-core configuration profiles use a handful of pipeline parameters to describe themselves. This information is then printed to the Nextflow log when you run a pipeline. You should not need to change these values when you run a pipeline.",
      properties: {
        custom_config_version: {
          type: "string",
          description: "Git commit id for Institutional configs.",
          default: "master",
          hidden: true,
          fa_icon: "fas fa-users-cog",
        },
        custom_config_base: {
          type: "string",
          description: "Base directory for Institutional configs.",
          default: "https://raw.githubusercontent.com/nf-core/configs/master",
          hidden: true,
          help_text:
            "If you're running offline, Nextflow will not be able to fetch the institutional config files from the internet. If you don't need them, then this is not a problem. If you do need them, you should download the files from the repo and tell Nextflow where to find them with this parameter.",
          fa_icon: "fas fa-users-cog",
        },
        config_profile_name: {
          type: "string",
          description: "Institutional config name.",
          hidden: true,
          fa_icon: "fas fa-users-cog",
        },
        config_profile_description: {
          type: "string",
          description: "Institutional config description.",
          hidden: true,
          fa_icon: "fas fa-users-cog",
        },
        config_profile_contact: {
          type: "string",
          description: "Institutional config contact information.",
          hidden: true,
          fa_icon: "fas fa-users-cog",
        },
        config_profile_url: {
          type: "string",
          description: "Institutional config URL link.",
          hidden: true,
          fa_icon: "fas fa-users-cog",
        },
      },
    },
    max_job_request_options: {
      title: "Max job request options",
      type: "object",
      fa_icon: "fab fa-acquisitions-incorporated",
      description:
        "Set the top limit for requested resources for any single job.",
      help_text:
        "If you are running on a smaller system, a pipeline step requesting more resources than are available may cause the Nextflow to stop the run with an error. These options allow you to cap the maximum resources requested by any single job so that the pipeline will run on your system.\n\nNote that you can not _increase_ the resources requested by any job using these options. For that you will need your own configuration file. See [the nf-core website](https://nf-co.re/usage/configuration) for details.",
      properties: {
        max_cpus: {
          type: "integer",
          description:
            "Maximum number of CPUs that can be requested for any single job.",
          default: 16,
          fa_icon: "fas fa-microchip",
          hidden: true,
          help_text:
            "Use to set an upper-limit for the CPU requirement for each process. Should be an integer e.g. `--max_cpus 1`",
        },
        max_memory: {
          type: "string",
          description:
            "Maximum amount of memory that can be requested for any single job.",
          default: "128.GB",
          fa_icon: "fas fa-memory",
          pattern: "^\\d+(\\.\\d+)?\\.?\\s*(K|M|G|T)?B$",
          hidden: true,
          help_text:
            "Use to set an upper-limit for the memory requirement for each process. Should be a string in the format integer-unit e.g. `--max_memory '8.GB'`",
        },
        max_time: {
          type: "string",
          description:
            "Maximum amount of time that can be requested for any single job.",
          default: "240.h",
          fa_icon: "far fa-clock",
          pattern: "^(\\d+\\.?\\s*(s|m|h|day)\\s*)+$",
          hidden: true,
          help_text:
            "Use to set an upper-limit for the time requirement for each process. Should be a string in the format integer-unit e.g. `--max_time '2.h'`",
        },
      },
    },
    generic_options: {
      title: "Generic options",
      type: "object",
      fa_icon: "fas fa-file-import",
      description:
        "Less common options for the pipeline, typically set in a config file.",
      help_text:
        "These options are common to all nf-core pipelines and allow you to customise some of the core preferences for how the pipeline runs.\n\nTypically these options would be set in a Nextflow config file loaded for all pipeline runs, such as `~/.nextflow/config`.",
      properties: {
        help: {
          type: ["string", "boolean"],
          description: "Display help text.",
          fa_icon: "fas fa-question-circle",
          hidden: true,
        },
        publish_dir_mode: {
          type: "string",
          default: "copy",
          description:
            "Method used to save pipeline results to output directory.",
          help_text:
            "The Nextflow `publishDir` option specifies which intermediate files should be saved to the output directory. This option tells the pipeline what method should be used to move these files. See [Nextflow docs](https://www.nextflow.io/docs/latest/process.html#publishdir) for details.",
          fa_icon: "fas fa-copy",
          enum: ["symlink", "rellink", "link", "copy", "copyNoFollow", "move"],
          hidden: true,
        },
        email_on_fail: {
          type: "string",
          description:
            "Email address for completion summary, only when pipeline fails.",
          fa_icon: "fas fa-exclamation-triangle",
          pattern:
            "^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})$",
          help_text:
            "An email address to send a summary email to when the pipeline is completed - ONLY sent if the pipeline does not exit successfully.",
          hidden: true,
        },
        plaintext_email: {
          type: "boolean",
          description: "Send plain-text email instead of HTML.",
          fa_icon: "fas fa-remove-format",
          hidden: true,
        },
        max_multiqc_email_size: {
          type: "string",
          description:
            "File size limit when attaching MultiQC reports to summary emails.",
          pattern: "^\\d+(\\.\\d+)?\\.?\\s*(K|M|G|T)?B$",
          default: "25.MB",
          fa_icon: "fas fa-file-upload",
          hidden: true,
        },
        monochrome_logs: {
          type: "boolean",
          description: "Do not use coloured log outputs.",
          fa_icon: "fas fa-palette",
          hidden: true,
        },
        multiqc_config: {
          type: "string",
          description: "Custom config file to supply to MultiQC.",
          fa_icon: "fas fa-cog",
          hidden: true,
        },
        tracedir: {
          type: "string",
          description: "Directory to keep pipeline Nextflow logs and reports.",
          default: "${params.outdir}/pipeline_info",
          fa_icon: "fas fa-cogs",
          hidden: true,
        },
        validate_params: {
          type: "boolean",
          description:
            "Boolean whether to validate parameters against the schema at runtime",
          default: true,
          fa_icon: "fas fa-check-square",
          hidden: true,
        },
        validationShowHiddenParams: {
          type: "boolean",
          fa_icon: "far fa-eye-slash",
          description: "Show all params when using `--help`",
          hidden: true,
          help_text:
            "By default, parameters set as _hidden_ in the schema are not shown on the command line when a user runs with `--help`. Specifying this option will tell the pipeline to show all parameters.",
        },
        enable_conda: {
          type: "boolean",
          description:
            "Run this workflow with Conda. You can also use '-profile conda' instead of providing this parameter.",
          hidden: true,
          fa_icon: "fas fa-bacon",
        },
      },
    },
  },
  allOf: [
    {
      $ref: "#/definitions/input_output_options",
    },
    {
      $ref: "#/definitions/reference_genome_options",
    },
    {
      $ref: "#/definitions/institutional_config_options",
    },
    {
      $ref: "#/definitions/max_job_request_options",
    },
    {
      $ref: "#/definitions/generic_options",
    },
  ],
};

export default class extends Controller {
  connect() {
    console.log(SCHEMA.definitions);
  }
}
