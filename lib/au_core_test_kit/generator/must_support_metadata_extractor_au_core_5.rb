require_relative 'must_support_metadata_extractor_au_core_4'

module AUCoreTestKit
  class Generator
    class MustSupportMetadataExtractorUsCore5
      attr_accessor :profile, :must_supports

      def initialize(profile, must_supports)
        self.profile = profile
        self.must_supports = must_supports
      end


      def au_core_4_extractor
        @au_core_4_extractor ||= MustSupportMetadataExtractorUsCore4.new(profile, must_supports)
      end

      def handle_special_cases
        add_must_support_choices
        remove_patient_address_period
        add_patient_uscdi_elements
        remove_survey_questionnaire_response
      end

      def add_must_support_choices
        au_core_4_extractor.add_must_support_choices

        more_choices = []

        case profile.type
        when 'CareTeam'
          more_choices << {
            target_profiles: [
              'http://hl7.org/fhir/us/core/StructureDefinition/au-core-practitioner',
              'http://hl7.org/fhir/us/core/StructureDefinition/au-core-practitionerrole'
            ]
          }
        when 'Condition'
          more_choices << {
            paths: ['onsetDateTime'],
            extension_ids: ['Condition.extension:assertedDate']
          }
        end

        if more_choices.present?
          must_supports[:choices] ||= []
          must_supports[:choices].concat(more_choices)
        end
      end

      def remove_patient_address_period
        au_core_4_extractor.remove_patient_address_period
      end

      def add_patient_uscdi_elements
        return unless profile.type == 'Patient'

        au_core_4_extractor.add_patient_uscdi_elements

        must_supports[:extensions] << {
          id: 'Patient.extension:genderIdentity',
          url: 'http://hl7.org/fhir/us/core/StructureDefinition/au-core-genderIdentity',
          uscdi_only: true
        }
        must_supports[:elements] << {
          path: 'address.use',
          fixed_value: 'old',
          uscdi_only: true
        }
        must_supports[:elements] << {
          path: 'name.use',
          fixed_value: 'old',
          uscdi_only: true
        }
      end

      def add_value_set_expansion
        add_document_reference_category_values
        add_service_request_category_values
      end

      # FHIR-37794 Server systems are not required to support US Core QuestionnaireResponse
      def remove_survey_questionnaire_response
        return unless profile.type == 'Observation' &&
          ['au-core-observation-survey', 'au-core-observation-sdoh-assessment'].include?(profile.id)

        element = must_supports[:elements].find { |element| element[:path] == 'derivedFrom' }
        element[:target_profiles].delete_if do |url|
          url == 'http://hl7.org/fhir/us/core/StructureDefinition/au-core-questionnaireresponse'
        end
      end
    end
  end
end