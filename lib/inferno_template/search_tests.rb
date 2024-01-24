module InfernoTemplate
    module SearchTests
        def test_search_conditions(search_params)
            fhir_search(:condition, params: search_params)
            assert_response_status(200)
            assert_resource_type(:bundle)
            extracted_resources = extract_resources_from_bundle(resource)
            filtered_conditions = filter_conditions(extracted_resources, search_params)
            assert filtered_conditions.length() > 0,
                "Number of results should be more than 0"
            assert filtered_conditions.length() == extracted_resources.length(),
                "Number of filtered results should be equal than before filter"
        end

        def test_search_patients(search_params)
            fhir_search(:patient, params: search_params)
            assert_response_status(200)
            assert_resource_type(:bundle)
            extracted_resources = extract_resources_from_bundle(resource)
            filtered_resources = filter_patients(extracted_resources, search_params)
            assert filtered_resources.length() > 0,
                "Number of results should be more than 0"
            assert filtered_resources.length() == extracted_resources.length(),
                "Number of filtered results should be equal than before filter"
        end
    end
end