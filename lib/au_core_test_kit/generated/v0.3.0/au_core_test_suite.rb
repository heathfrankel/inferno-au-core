require 'inferno/dsl/oauth_credentials'
require_relative '../../version'
require_relative '../../provenance_validator'
require_relative '../../au_core_options'

require_relative 'bmi_group'
require_relative 'bodyweight_group'
require_relative 'oxygensat_group'
require_relative 'bloodpressure_group'
require_relative 'bodyheight_group'
require_relative 'diagnosticresult_path_group'
require_relative 'lipid_result_group'
require_relative 'headcircum_group'
require_relative 'bodytemp_group'
require_relative 'heartrate_group'
require_relative 'waistcircum_group'
require_relative 'vitalspanel_group'
require_relative 'resprate_group'
require_relative 'diagnosticresult_imag_group'
require_relative 'diagnosticresult_group'
require_relative 'sexassignedatbirth_group'
require_relative 'smokingstatus_group'

module AUCoreTestKit
  module AUCoreV030
    class AUCoreTestSuite < Inferno::TestSuite
      title 'AU Core v0.3.0'
      description %(
        The US Core Test Kit tests systems for their conformance to the [US Core
        Implementation Guide]().

        HL7® FHIR® resources are validated with the Java validator using
        `tx.fhir.org` as the terminology server. Users should note that the
        although the ONC Certification (g)(10) Standardized API Test Suite
        includes tests from this suite, [it uses a different method to perform
        terminology
        validation](https://github.com/onc-healthit/onc-certification-g10-test-kit/wiki/FAQ#q-why-do-some-resources-fail-in-au-core-test-kit-with-terminology-validation-errors).
        As a result, resource validation results may not be consistent between
        the US Core Test Suite and the ONC Certification (g)(10) Standardized
        API Test Suite.
      )
      version VERSION

      VALIDATION_MESSAGE_FILTERS = [
        %r{Sub-extension url 'introspect' is not defined by the Extension http://fhir-registry\.smarthealthit\.org/StructureDefinition/oauth-uris},
        %r{Sub-extension url 'revoke' is not defined by the Extension http://fhir-registry\.smarthealthit\.org/StructureDefinition/oauth-uris},
        /Observation\.effective\.ofType\(Period\): .*vs-1:/, # Invalid invariant in FHIR v4.0.1
        /Observation\.effective\.ofType\(Period\): .*au-core-1:/, # Invalid invariant in US Core v3.1.1
        /Provenance.agent\[\d*\]: Rule provenance-1/, #Invalid invariant in US Core v5.0.1
        %r{Unknown Code System 'http://hl7.org/fhir/us/core/CodeSystem/au-core-tags'}, # Validator has an issue with this US Core 5 code system in US Core 6 resource
        %r{URL value 'http://hl7.org/fhir/us/core/CodeSystem/au-core-tags' does not resolve} # Validator has an issue with this US Core 5 code system in US Core 6 resource
      ].freeze

      VERSION_SPECIFIC_MESSAGE_FILTERS = [].freeze

      def self.metadata
        @metadata ||= YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true)[:groups].map do |raw_metadata|
            Generator::GroupMetadata.new(raw_metadata)
          end
      end

      validator do
        url ENV.fetch('V030_VALIDATOR_URL', 'http://validator_service:4567')
        message_filters = VALIDATION_MESSAGE_FILTERS + VERSION_SPECIFIC_MESSAGE_FILTERS

        exclude_message do |message|

          message_filters.any? { |filter| filter.match? message.message }
        end

        perform_additional_validation do |resource, profile_url|
          ProvenanceValidator.validate(resource) if resource.instance_of?(FHIR::Provenance)
        end
      end

      id :au_core_v030

      input :url,
        title: 'FHIR Endpoint',
        description: 'URL of the FHIR endpoint'
      input :smart_credentials,
        title: 'OAuth Credentials',
        type: :oauth_credentials,
        optional: true

      fhir_client do
        url :url
        oauth_credentials :smart_credentials
      end


      suite_option :smart_app_launch_version,
        title: 'SMART App Launch Version',
        list_options: [
          {
            label: 'SMART App Launch 1.0.0',
            value: USCoreOptions::SMART_1
          },
          {
            label: 'SMART App Launch 2.0.0',
            value: USCoreOptions::SMART_2
          }
        ]

      group from: :au_core_smart_app_launch

      group do
        title 'US Core FHIR API'
        id :au_core_v030_fhir_api

        group from: :au_core_v030_capability_statement
      
        group from: :au_core_v030_bmi
        group from: :au_core_v030_bodyweight
        group from: :au_core_v030_oxygensat
        group from: :au_core_v030_bloodpressure
        group from: :au_core_v030_bodyheight
        group from: :au_core_v030_diagnosticresult_path
        group from: :au_core_v030_lipid_result
        group from: :au_core_v030_headcircum
        group from: :au_core_v030_bodytemp
        group from: :au_core_v030_heartrate
        group from: :au_core_v030_waistcircum
        group from: :au_core_v030_vitalspanel
        group from: :au_core_v030_resprate
        group from: :au_core_v030_diagnosticresult_imag
        group from: :au_core_v030_diagnosticresult
        group from: :au_core_v030_sexassignedatbirth
        group from: :au_core_v030_smokingstatus
        group from: :au_core_v400_clinical_notes_guidance
        group from: :au_core_311_data_absent_reason
      end
    end
  end
end
