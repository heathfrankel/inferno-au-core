module AUCoreTestKit
    module SearchTests
        def test_search_resources resource_type, search_params
            fhir_search resource_type, params: search_params
            assert_response_status 200
            assert_resource_type :bundle
            extracted_resources = extract_resources_from_bundle resource
            filtered_resources = filter_resources resource_type, extracted_resources, search_params
            assert filtered_resources.length > 0,
                "Number of results should be more than 0"
            assert filtered_resources.length == extracted_resources.length,
                "Number of filtered results should be equal than before filter"
        end

        def filter_resources resource_type, resources, search_params
            case resource_type
            when :condition
                filter_conditions resources, search_params
            when :patient
                filter_patients resources, search_params
            when :allergyIntolerance
                filter_allergy_intolerance resources, search_params
            else
                raise ArgumentError, "Unknown filter resourceType: #{resource_type}"
            end
        end
    end
end