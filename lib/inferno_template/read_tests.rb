module InfernoTemplate
    module ReadTests
        def test_read_resources resource_type, id
            fhir_read resource_type, id
            assert_response_status 200
            assert_resource_type resource_type
            assert resource.id == id,
                    "Requested resource with id #{id}, received resource with id #{resource.id}"
        end
    end
end