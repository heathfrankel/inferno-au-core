require_relative 'utils'
require_relative 'search_tests'
require_relative 'read_tests'

module InfernoTemplate
    class AllergyIntoleranceReadAndSearchGroup < Inferno::TestGroup
        include Utils

        title 'AllergyIntolerance: Read and Search'
        description 'Source: https://confluence.hl7.org/pages/viewpage.action?pageId=203358353'
        id :allergy_intolerance_read_and_search_group

        test do
            include ReadTests
            title 'READ'
            description %(
                FHIR client retrieves the FHIR client retrieves the AllergyIntolerance resource with the Id lactose.
            )

            run do
                test_read_resources :allergyIntolerance, 'lactose'
            end
        end

        test do
            include SearchTests
            title 'SEARCH: _id'
            description %(
                Search AllergyIntolerance using the id 'penicillin'
            )

            run do
                [
                    {:_id => "penicillin"},
                ].each { |search_params| test_search_resources :allergyIntolerance, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH patient'
            description %(
                Search using the patient id 'dan-harry' \n
                Search using the patient id 'baby-smith-john'
            )

            run do
                [
                    {:patient => "dan-harry"},
                    {:patient => "baby-smith-john"},
                ].each { |search_params| test_search_resources :allergyIntolerance, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH clinical-status'
            description %(
                Search using the clinical-status 'active'
            )

            run do
                test_search_resources :allergyIntolerance, {"clinical-status" => "active"}
            end
        end
    end
end
