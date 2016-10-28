require 'singleton'

module CagnutPicard
  class Configuration
    include Singleton
    attr_accessor :rg_str_picard, :add_or_replace_readgroups_params, :sort_sam_params,
                  :build_bam_index_params, :quailty_score_distribution_params,
                  :collect_gc_bias_metrics_params, :collect_insert_size_metrics_params,
                  :collect_multiple_metrics_params, :markduplicate_params,
                  :mean_quality_by_cycle_params

    class << self
      def load config, params
        instance.load config, params
      end
    end

    def load config, params
      @config = config
      @params = params
      generate_rg_str
      attributes.each do |name, value|
        send "#{name}=", value if respond_to? "#{name}="
      end
    end

    def attributes
      {
        rg_str_picard: @config['sample']['rg_str_picard'],
        add_or_replace_readgroups_params: add_java_params(@params['add_or_replace_readgroups'], true),
        build_bam_index_params: add_java_params(@params['build_bam_index']),
        collect_gc_bias_metrics_params: add_java_params(@params['collect_gc_bias_metrics']),
        collect_insert_size_metrics_params: add_java_params(@params['collect_insert_size_metrics']),
        collect_multiple_metrics_params: add_java_params(@params['collect_multiple_metrics']),
        markduplicate_params: add_java_params(@params['markduplicate']),
        mean_quality_by_cycle_params: add_java_params(@params['mean_quality_by_cycle']),
        quailty_score_distribution_params: add_java_params(@params['quailty_score_distribution']),
        sort_sam_params: add_java_params(@params['sort_sam'])
      }
    end

    def add_java_params method_params, verbose=false
      return if method_params.blank?
      array = method_params['java'].dup
      array << "-verbose:sizes" if verbose
      array << "-jar #{@config['tools']['picard']}"
      {
        'java' => array,
        'params' => method_params['params']
      }
    end

    def generate_rg_str
      @config['samples'].each do |sample|
        arg = %W(
          ID=#{sample['rgid']}
          SM=#{sample['name']}
          PL=#{@config['info']['pl']}
          PU=#{sample['pu']}
          LB=#{@config['info']['lb']}
          DS=#{@config['info']['ds']}
          CN=#{@config['info']['cn']}
        )
        rg_str_picard = { 'rg_str_picard' => arg.join(' ') }
        sample.merge! rg_str_picard
      end

    end
  end
end
