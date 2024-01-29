module AUCoreTestKit
  class Generator
    module SpecialCases
      RESOURCES_TO_EXCLUDE = [
        'Location',
        'Medication',
        'PractitionerRole'
      ].freeze

      PROFILES_TO_EXCLUDE = [
        'http://hl7.org/fhir/us/core/StructureDefinition/au-core-observation-survey',
        'http://hl7.org/fhir/us/core/StructureDefinition/au-core-vital-signs'
      ].freeze

      class << self
        # TODO: Why last group for Observation is empty?
        def exclude_group?(group)
          if group
            RESOURCES_TO_EXCLUDE.include?(group.resource)
          end
        end
      end
    end
  end
end
