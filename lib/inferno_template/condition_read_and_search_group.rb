require_relative 'utils'

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
            title 'SEARCH: _id'
            description %(
                Find condition record using the _id parameter 'fever' \n
                Find patient record using the _id parameter 'nailwound'
            )
            makes_request :condition

            run do
                condition_ids = ["fever", "nailwound"]
                for condition_id in condition_ids do
                    fhir_search(:condition, params: { _id: condition_id })
                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        id: condition_id,
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH patient'
            description %(
                Find condition record with the patient parameter 'wang-li' \n
                Find condition record with the patient parameter 'dan-harry'
            )
            makes_request :condition

            run do
                patient_id_arr = ["wang-li", "dan-harry"]

                for patient_id in patient_id_arr do
                    fhir_search(:condition, params: { patient: patient_id })
                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        subject: patient_id,
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH: patient+category'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and category parameter 'problem-list-item' \n
                Find condition records using combination of patient parameter 'wang-li' and category parameter 'http://terminology.hl7.org/CodeSystem/condition-category|encounter-diagnosis'
            )
            makes_request :condition

            run do
                search_param_arr = [
                    {"patient_id" => 'smith-emma', "category" => 'problem-list-item'},
                    {"patient_id" => 'wang-li', "category" => 'http://terminology.hl7.org/CodeSystem/condition-category|encounter-diagnosis'},
                ]
                for search_param in search_param_arr do
                    patient_id = search_param["patient_id"]
                    category = search_param["category"]

                    fhir_search(:condition, params: { patient: patient_id, category: category })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        subject: patient_id,
                        category: category
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH: patient+clinical-status'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and clinical-status parameter 'active' \n
                Find condition records using combination of patient parameter 'wang-li' and clinical-status parameter 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'
            )
            makes_request :condition

            run do
                search_param_arr = [
                    {"patient_id" => 'smith-emma', "clinical_status" => 'active'},
                    {"patient_id" => 'wang-li', "clinical_status" => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'},
                ]
                for search_param in search_param_arr do
                    patient_id = search_param["patient_id"]
                    clinical_status = search_param["clinical_status"]

                    fhir_search(:condition, params: { patient: patient_id, "clinical-status": clinical_status })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        subject: patient_id,
                        clinicalStatus: clinical_status
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH: patient+category+clinical-status'
            description %(
                Find condition records using combination of patient parameter 'smith-emma' and category parameter 'problem-list-item' and clinical-status parameter 'active' \n
                Find condition records using combination of patient parameter 'wang-li' and category parameter 'http://terminology.hl7.org/CodeSystem/condition-category|problem-list-item' and clinical-status parameter 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'
            )
            makes_request :condition

            run do
                search_param_arr = [
                    {"patient_id" => 'smith-emma', "category" => "problem-list-item", "clinical_status" => 'active'},
                    {"patient_id" => 'wang-li', "category" => "http://terminology.hl7.org/CodeSystem/condition-category|problem-list-item", "clinical_status" => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active'},
                ]
                for search_param in search_param_arr do
                    patient_id = search_param["patient_id"]
                    category = search_param["category"]
                    clinical_status = search_param["clinical_status"]

                    fhir_search(:condition, params: { patient: patient_id, category: category, "clinical-status": clinical_status })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        subject: patient_id,
                        category: category,
                        clinicalStatus: clinical_status
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH: patient+code'
            description %(
                Find condition records using combination of patient parameter 'wang-li' and code parameter 'http://snomed.info/sct%7C394659003' \n
                Find condition records using combination of patient parameter 'wang-li' and one of the following code parameters: 'http://snomed.info/sct%7C283680004', 'http://snomed.info/sct%7C394659003', and 'http://snomed.info/sct%7C54329005'
            )
            makes_request :condition

            run do
                search_param_arr = [
                    {"patient_id" => 'wang-li', "code" => 'http://snomed.info/sct|394659003'},
                    {"patient_id" => 'wang-li', "code" => 'http://snomed.info/sct|394659003,http://snomed.info/sct|283680004,http://snomed.info/sct|54329005'},
                ]
                for search_param in search_param_arr do
                    patient_id = search_param["patient_id"]
                    code = search_param["code"]

                    fhir_search(:condition, params: { patient: patient_id, code: code })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                        subject: patient_id,
                        code: code,
                    })
                    assert filtered_conditions.length() > 0,
                        "Number of results should be more than 0"
                end
            end
        end

        test do
            title 'SEARCH: patient+onset-date'
            description %(
                Find condition records for patient 'wang-li' that occurred from 01 Jan 2014 onwards \n
            )
            makes_request :condition

            run do
                onset_date_ge = '2014-01-01T00:00:00Z'
                patient_id = "wang-li"
                fhir_search(:condition, params: { patient: patient_id, "onset-date": "ge" + onset_date_ge })
                assert_response_status(200)
                assert_resource_type(:bundle)
                filtered_conditions = filter_conditions(extract_resources_from_bundle(resource), {
                    subject: patient_id,
                    onSetDateTimeGE: onset_date_ge,
                })
                assert filtered_conditions.length() > 0,
                    "Number of results should be more than 0"
            end
        end

        test do
            title 'SEARCH: patient.identifier'
            description %(
                Find condition for patient with identifier 'http://ns.electronichealth.net.au/id/hi/ihi/1.0|8003608833357361' \n
            )
            makes_request :condition

            run do
                patient_identifier = 'http://ns.electronichealth.net.au/id/hi/ihi/1.0|8003608833357361'
                fhir_search(:condition, params: { "patient.identifier": patient_identifier })
                assert_response_status(200)
                assert_resource_type(:bundle)
                assert resource.entry.length() > 0,
                    "Number of results should be more than 0"
            end
        end
    end
end
