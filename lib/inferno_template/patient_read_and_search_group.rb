require_relative 'utils'
require_relative 'search_tests'

module InfernoTemplate
    class PatientReadAndSearchGroup < Inferno::TestGroup
        include Utils

        title 'Patient: Read and Search'
        description 'Source: https://confluence.hl7.org/pages/viewpage.action?pageId=203358353'
        id :patient_read_and_search_group

        test do
            title 'READ'
            description %(
                FHIR client retrieves the patient resource with the Id.
            )

            makes_request :patient

            run do
                patient_ids = ["wang-li", "italia-sofia"]
                for patient_id in patient_ids do
                    fhir_read(:patient, patient_id, name: :patient)
                    assert_response_status(200)
                    assert_resource_type(:patient)
                    assert resource.id == patient_id,
                            "Requested resource with id #{patient_id}, received resource with id #{resource.id}"
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: _id'
            description %(
                FHIR client searches the FHIR server for patients with a given id
            )
            makes_request :patient

            run do
                search_params_arr = [{:_id => "wang-li"}, {:_id => "italia-sofia"}]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH identifier'
            description %(
                Find patient record using the identifier parameter "http://ns.electronichealth.net.au/id/hi/ihi/1.0|7C8003608833357361" \n
                Find patient record using the identifier parameter "http://ns.electronichealth.net.au/id/dva|NBUR9080" \n
                Find patient record using the identifier parameter "http://ns.electronichealth.net.au/id/medicare-number|1234567892
            )
            makes_request :patient

            run do
                search_params_arr = [
                    {:_identifier => "http://ns.electronichealth.net.au/id/hi/ihi/1.0|7C8003608833357361"},
                    {:_identifier => "http://ns.electronichealth.net.au/id/dva|NBUR9080"},
                    {:_identifier => "http://ns.electronichealth.net.au/id/medicare-number|1234567892"}
                ]

                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: birthdate+family'
            description %(
                Find patient records using combination of birthdate parameter '1999-12-19' and family name parameter 'smith' \n
                Find patient records using combination of birthdate parameter '1968-10-11' and family name parameter 'Bennelong'
            )
            makes_request :patient

            run do
                search_params_arr = [
                    {:birthdate => '1999-12-19', :family => 'smith'},
                    {:birthdate => '1968-10-11', :family => 'Bennelong'},
                ]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: birthdate+name'
            description %(
                Find patient records using combination of birthdate parameter '1939-08-25' and name parameter 'Dan'
            )
            makes_request :patient

            run do
                test_search_patients({ birthdate: '1939-08-25', name: 'Dan' })
            end
        end

        test do
            include SearchTests
            title 'SEARCH: family'
            description %(
                Find patient records using family name parameter 'smith' \n
                Find patient records using family name parameter 'Bennelong'
            )
            makes_request :patient

            run do
                search_params_arr = [{:family => "smith"}, {:family => "Bennelong"}]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: family+gender'
            description %(
                Find patient records using combination of family name parameter 'smith' and gender parameter 'female' \n
                Find patient records using combination of family name parameter 'Wang' and gender parameter 'male'
            )
            makes_request :patient

            run do
                search_params_arr = [
                    {:family => "smith", :gender => "female"},
                    {:family => "Wang", :gender => "male"},
                ]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: gender+name'
            description %(
                Find patient records using combination of name parameter 'smith' and gender parameter 'female' \n
                Find patient records using combination of name parameter 'Wang' and gender parameter 'male'
            )
            makes_request :patient

            run do
                search_params_arr = [
                    {:name => "smith", :gender => "female"},
                    {:name => "Wang", :gender => "male"},
                ]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: name'
            description %(
                Find patient records using name parameter 'Dan' \n
                Find patient records using name parameter 'Em'
            )
            makes_request :patient

            run do
                search_params_arr = [
                    {:name => "Dan"},
                    {:name => "Em"},
                ]
                for search_params in search_params_arr do
                    test_search_patients(search_params)
                end
            end
        end
    end
end
