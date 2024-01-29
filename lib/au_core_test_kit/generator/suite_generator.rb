require_relative 'naming'
require_relative 'special_cases'

module AUCoreTestKit
  class Generator
    class SuiteGenerator
      class << self
        def generate(ig_metadata, base_output_dir)
          new(ig_metadata, base_output_dir).generate
        end
      end

      attr_accessor :ig_metadata, :base_output_dir

      def initialize(ig_metadata, base_output_dir)
        self.ig_metadata = ig_metadata
        self.base_output_dir = base_output_dir
      end

      def version_specific_message_filters
        []
      end

      def template
        @template ||= File.read(File.join(__dir__, 'templates', 'suite.rb.erb'))
      end

      def output
        @output ||= ERB.new(template).result(binding)
      end

      def base_output_file_name
        "au_core_test_suite.rb"
      end

      def class_name
        "AUCoreTestSuite"
      end

      def module_name
        "AUCore#{ig_metadata.reformatted_version.upcase}"
      end

      def output_file_name
        File.join(base_output_dir, base_output_file_name)
      end

      def suite_id
        "au_core_#{ig_metadata.reformatted_version}"
      end

      def fhir_api_group_id
        "au_core_#{ig_metadata.reformatted_version}_fhir_api"
      end

      def title
        "AU Core #{ig_metadata.ig_version}"
      end

      def validator_env_name
        "#{ig_metadata.reformatted_version.upcase}_VALIDATOR_URL"
      end

      def ig_link
        case ig_metadata.ig_version
        when 'v5.0.1'
          'http://hl7.org/fhir/us/core/STU5.0.1'
        when 'v4.0.0'
          'http://hl7.org/fhir/us/core/STU4'
        when 'v3.1.1'
          'http://hl7.org/fhir/us/core/STU3.1.1'
        end
      end

      def generate
        File.open(output_file_name, 'w') { |f| f.write(output) }
      end

      def groups
        ig_metadata.ordered_groups
          .reject { |group| SpecialCases.exclude_group? group }
      end

      def group_id_list
        # TODO: Remove compact
        @group_id_list ||=
          groups.compact.map(&:id)
      end

      def group_file_list
        # TODO: Remove compact
        @group_file_list ||=
          groups.compact.map { |group| group.file_name.delete_suffix('.rb') }
      end

      def capability_statement_file_name
        "../../custom_groups/#{ig_metadata.ig_version}/capability_statement_group"
      end

      def capability_statement_group_id
        "au_core_#{ig_metadata.reformatted_version}_capability_statement"
      end

      def clinical_notes_guidance_file_name
        if ig_metadata.ig_version == 'v3.1.1'
          "../../custom_groups/#{ig_metadata.ig_version}/clinical_notes_guidance_group"
        else
          '../../custom_groups/v4.0.0/clinical_notes_guidance_group'
        end
      end

      def clinical_notes_guidance_group_id
        if ig_metadata.reformatted_version == 'v311'
          "au_core_#{ig_metadata.reformatted_version}_clinical_notes_guidance"
        else
          'au_core_v400_clinical_notes_guidance'
        end
      end
    end
  end
end
