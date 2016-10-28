module CagnutPicard
  class CollectGcBiasMetrics
    extend Forwardable

    def_delegators :'Cagnut::Configuration.base', :sample_name, :jobs_dir, :dodebug,
                   :ref_fasta, :prefix_name, :java_path
    def_delegators :'CagnutPicard.config', :collect_gc_bias_metrics_params

    def initialize opts = {}
      @tmp_dir = opts[:dirs][:tmp_dir]
      @job_name = "#{prefix_name}_collect_gc_bias_metrics_#{sample_name}"
      @input = opts[:input].nil? ? "#{opts[:dirs][:input]}/#{sample_name}_recal.bam" : opts[:input]
      @output = "#{opts[:dirs][:output]}/Gc_Bias_Metrics"
      @chart_output = "#{opts[:dirs][:output]}/Gc_bias_#{sample_name}.pdf"
      @summary_output = "#{opts[:dirs][:output]}/sum_out_gc"
    end

    def run previous_job_id = nil
      puts "Submitting Picard CollectGcBiasMetrics #{sample_name} Jobs "
      script_name = generate_script
      ::Cagnut::JobManage.submit script_name, @job_name, queuing_options(previous_job_id)
      @job_name
    end

    def queuing_options previous_job_id = nil
      {
        previous_job_id: previous_job_id,
        adjust_memory: ['h_vmem=5G'],
        tools: ['picard', 'collect_gc_bias_metrics']
      }
    end

    def collect_gc_bias_metrics_options
      array = collect_gc_bias_metrics_params['params'].dup
      array << "REFERENCE_SEQUENCE=#{ref_fasta}"
      array << "TMP_DIR=#{@tmp_dir}"
      array << "INPUT=#{@input}"
      array << "OUTPUT=#{@output}"
      array << "CHART_OUTPUT=#{@chart_output}"
      array << "SUMMARY_OUTPUT=#{@summary_output}"
      array.uniq
    end

    def modified_java_array
      array = collect_gc_bias_metrics_params['java'].dup
      array << 'CollectGcBiasMetrics'
      array.unshift(java_path).uniq
    end

    def params_combination_hash
      @params_combination_hash ||= {
        'java' => modified_java_array,
        'params' => collect_gc_bias_metrics_options
      }
    end

    def generate_script
      script_name = 'picard_collect_gc_bias_metrics'
      file = File.join jobs_dir, "#{script_name}.sh"
      File.open(file, 'w') do |f|
        f.puts <<-BASH.strip_heredoc
          #!/bin/bash

          cd "#{jobs_dir}/../"
          echo "#{script_name} is starting at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"
          #{params_combination_hash['java'].join("\s")} \\
            #{params_combination_hash['params'].join(" \\\n            ")} \\
            #{::Cagnut::JobManage.run_local}

          EXITSTATUS=$?
          if [ ! -s "#{@chart_output}" ]; then exit 100;fi;
          echo "#{script_name} is finished at $(date +%Y%m%d%H%M%S)" >> "#{jobs_dir}/finished_jobs"

          exit $EXITSTATUS
        BASH
      end
      File.chmod(0700, file)
      script_name
    end
  end
end
