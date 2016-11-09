module CagnutPicard
  module CheckTools
    def check_tool tools_path, refs=nil
      super if defined?(super)
      ver = check_Picard tools_path['picard'] if @java
      check_picard_dict refs['ref_fasta'] if !ver.blank?
    end

    def check_Picard path
      check_tool_ver 'Picard' do
        `#{@java} -jar #{path} AddOrReplaceReadGroups --version 2>&1` if path
      end
    end

    def check_picard_dict ref_path
      tool = 'Sequence Dictionary'
      file = ref_path.gsub '.fasta', '.dict'
      command =
        "#{@java} -jar #{@config['tools']['picard']} CreateSequenceDictionary REFERENCE=#{ref_path} OUTPUT=#{file}"
      check_ref_related file, tool, command
    end

    def check_ref_related file, tool, command
      if File.exist?(file)
        puts "\t#{tool}: Done"
      else
        puts "\t#{tool}: Not Found!"
        puts "\tPlease execute command:"
        puts "\t\t#{command}"
        @check_completed = false
      end
    end
  end
end

Cagnut::Configuration::Checks::Tools.prepend CagnutPicard::CheckTools
