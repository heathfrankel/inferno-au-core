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

            run do
                [
                    {:_id => "wang-li"},
                    {:_id => "italia-sofia"}
                ].each { |search_params| test_search_resources :patient, search_params }
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

            run do
                [
                    {:_identifier => "http://ns.electronichealth.net.au/id/hi/ihi/1.0|7C8003608833357361"},
                    {:_identifier => "http://ns.electronichealth.net.au/id/dva|NBUR9080"},
                    {:_identifier => "http://ns.electronichealth.net.au/id/medicare-number|1234567892"}
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: birthdate+family'
            description %(
                Find patient records using combination of birthdate parameter '1999-12-19' and family name parameter 'smith' \n
                Find patient records using combination of birthdate parameter '1968-10-11' and family name parameter 'Bennelong'
            )

            run do
                [
                    {:birthdate => '1999-12-19', :family => 'smith'},
                    {:birthdate => '1968-10-11', :family => 'Bennelong'},
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: birthdate+name'
            description %(
                Find patient records using combination of birthdate parameter '1939-08-25' and name parameter 'Dan'
            )

            run do
                test_search_resources :patient, { birthdate: '1939-08-25', name: 'Dan' }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: family'
            description %(
                Find patient records using family name parameter 'smith' \n
                Find patient records using family name parameter 'Bennelong'
            )

            run do
                [
                    {:family => "smith"},
                    {:family => "Bennelong"}
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: family+gender'
            description %(
                Find patient records using combination of family name parameter 'smith' and gender parameter 'female' \n
                Find patient records using combination of family name parameter 'Wang' and gender parameter 'male'
            )

            run do
                [
                    {:family => "smith", :gender => "female"},
                    {:family => "Wang", :gender => "male"},
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: gender+name'
            description %(
                Find patient records using combination of name parameter 'smith' and gender parameter 'female' \n
                Find patient records using combination of name parameter 'Wang' and gender parameter 'male'
            )

            run do
                [
                    {:name => "smith", :gender => "female"},
                    {:name => "Wang", :gender => "male"},
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end

        test do
            include SearchTests
            title 'SEARCH: name'
            description %(
                Find patient records using name parameter 'Dan' \n
                Find patient records using name parameter 'Em'
            )

            run do
                [
                    {:name => "Dan"},
                    {:name => "Em"},
                ].each { |search_params| test_search_resources :patient, search_params }
            end
        end
    end
end
