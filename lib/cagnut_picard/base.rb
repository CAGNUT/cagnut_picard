require 'cagnut_picard/functions/add_or_replace_readgroups'
require 'cagnut_picard/functions/markdup'
require 'cagnut_picard/functions/build_bam_index'
require 'cagnut_picard/functions/mean_quality_by_cycle'
require 'cagnut_picard/functions/quality_score_distribution'
require 'cagnut_picard/functions/collect_gc_bias_metrics'
require 'cagnut_picard/functions/collect_insert_size_metrics'
require 'cagnut_picard/functions/sort_sam'
require 'cagnut_picard/functions/collect_multiple_metrics'


module CagnutPicard
  class Base
    def add_or_replace_readgroups dirs, previous_job_id = nil, input = nil
      opts = { input: input, dirs: dirs }
      CagnutPicard::AddOrReplaceReadGroups.new(opts).run previous_job_id
    end

    def markdup dirs, previous_job_id, input = nil
      opts = { input: input, dirs: dirs }
      CagnutPicard::Markdup.new(opts).run previous_job_id
    end

    def build_bam_index dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::BuildBamIndex.new(opts).run previous_job_id
    end

    def mean_quality_by_cycle dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::MeanQualityByCycle.new(opts).run previous_job_id
    end

    def quality_score_distribution dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::QualityScoreDistribution.new(opts).run previous_job_id
    end

    def collect_gc_bias_metrics dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::CollectGcBiasMetrics.new(opts).run previous_job_id
    end

    def collect_insert_size_metrics dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::CollectInsertSizeMetrics.new(opts).run previous_job_id
    end

    def sort_sam dirs, previous_job_id, input = nil
      opts = { input: input, dirs: dirs }
      CagnutPicard::SortSam.new(opts).run previous_job_id
    end

    def collect_multiple_metrics dirs, previous_job_id, input
      opts = { input: input, dirs: dirs }
      CagnutPicard::CollectMultipleMetrics.new(opts).run previous_job_id
    end
  end
end
