require_relative 'utils'
require_relative 'search_tests'

module InfernoTemplate
    class ConditionReadAndSearchGroup < Inferno::TestGroup
        include Utils

        title 'Condition: Read and Search'
        description 'Source: https://confluence.hl7.org/pages/viewpage.action?pageId=203358353'
        id :condition_read_and_search_group

        test do
            title 'READ'
            description %(
                Find condition record using the id parameter 'fever' \n
                Find condition record using the id parameter 'nailwound'
            )

            makes_request :condition

            run do
                condition_ids = ["fever", "nailwound"]
                for condition_id in condition_ids do
                    fhir_read(:condition, condition_id, name: :condition)
                    assert_response_status(200)
                    assert_resource_type(:condition)
                    assert resource.id == condition_id,
                        "Requested resource with id #{condition_id}, received resource with id #{resource.id}"
                end
            end
        end


        test do
            include SearchTests
            title 'SEARCH: _id'
            description %(
                Find condition record using the _id parameter 'fever' \n
                Find patient record using the _id parameter 'nailwound'
            )
            makes_request :condition

            run do
                search_params_arr = [{:_id => "fever"}, {:_id => "nailwound"}]
                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH patient'
            description %(
                Find condition record with the patient parameter 'wang-li' \n
                Find condition record with the patient parameter 'dan-harry'
            )
            makes_request :condition

            run do
                search_params_arr = [{:patient => "wang-li"}, {:patient => "dan-harry"}]

                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: patient+category'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and category parameter 'problem-list-item' \n
                Find condition records using combination of patient parameter 'wang-li' and category parameter 'http://terminology.hl7.org/CodeSystem/condition-category|encounter-diagnosis'
            )
            makes_request :condition

            run do
                search_params_arr = [
                    {:patient => 'smith-emma', :category => 'problem-list-item'},
                    {:patient => 'wang-li', :category => 'http://terminology.hl7.org/CodeSystem/condition-category|encounter-diagnosis'},
                ]
                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: patient+clinical-status'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and clinical-status parameter 'active' \n
                Find condition records using combination of patient parameter 'wang-li' and clinical-status parameter 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'
            )
            makes_request :condition

            run do
                search_params_arr = [
                    {:patient => 'smith-emma', "clinical-status" => 'active'},
                    {:patient => 'wang-li', "clinical-status" => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'},
                ]
                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: patient+category+clinical-status'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and category parameter 'problem-list-item' and clinical-status parameter 'active' \n
                Find condition records using combination of patient parameter 'wang-li' and category parameter 'http://terminology.hl7.org/CodeSystem/condition-category|problem-list-item' and clinical-status parameter 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'
            )
            makes_request :condition

            run do
                search_params_arr = [
                    {:patient => 'smith-emma', :category => "problem-list-item", "clinical-status" => 'active'},
                    {:patient => 'wang-li', :category => "http://terminology.hl7.org/CodeSystem/condition-category|problem-list-item", "clinical-status" => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'},
                ]
                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: patient+code'
            description %(
                Find condition records using combination of patient parameter 'wang-li' and code parameter 'http://snomed.info/sct%7C394659003' \n
                Find condition records using combination of patient parameter 'wang-li' and one of the following code parameters: 'http://snomed.info/sct%7C283680004', 'http://snomed.info/sct%7C394659003', and 'http://snomed.info/sct%7C54329005'
            )
            makes_request :condition

            run do
                search_params_arr = [
                    {:patient => 'wang-li', :code => 'http://snomed.info/sct|394659003'},
                    {:patient => 'wang-li', :code => 'http://snomed.info/sct|394659003,http://snomed.info/sct|283680004,http://snomed.info/sct|54329005'},
                ]
                for search_params in search_params_arr do
                    test_search_conditions(search_params)
                end
            end
        end

        test do
            include SearchTests
            title 'SEARCH: patient+onset-date'
            description %(
                Find condition records for patient 'wang-li' that occurred from 01 Jan 2014 onwards \n
            )
            makes_request :condition

            run do
                test_search_conditions({ :patient => "wang-li", "onset-date" => "ge2014-01-01T00:00:00Z" })
            end
        end

        # test do
        #     title 'SEARCH: patient.identifier'
        #     description %(
        #         Find condition for patient with identifier 'http://ns.electronichealth.net.au/id/hi/ihi/1.0|8003608833357361' \n
        #     )
        #     makes_request :condition

        #     run do
        #         patient_identifier = 'http://ns.electronichealth.net.au/id/hi/ihi/1.0|8003608833357361'
        #         fhir_search(:condition, params: { "patient.identifier": patient_identifier })
        #         assert_response_status(200)
        #         assert_resource_type(:bundle)
        #         assert resource.entry.length() > 0,
        #             "Number of results should be more than 0"
        #     end
        # end
    end
end
