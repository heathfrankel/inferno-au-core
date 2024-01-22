module InfernoTemplate
    class ConditionReadAndSearchGroup < Inferno::TestGroup
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
                    assert resource.entry.first().resource.id == condition_id,
                        "Requested resource with id #{condition_id}, received resource with id #{resource.entry.first().resource.id}"
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
                    assert resource.entry.length() > 0
                    subject_id = resource.entry.first().resource.subject.reference.split('/').last()
                    assert subject_id == patient_id, "Result subject ID #{subject_id} should be equal to #{patient_id}"
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
                    splitted_category = category.split('|')

                    fhir_search(:condition, params: { patient: patient_id, category: category })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    assert resource.entry.length() > 0
                    result_patient_id = resource.entry.first().resource.subject.reference.split('/').last()
                    assert result_patient_id == patient_id,
                        "Requested resource with id #{result_patient_id}, received resource with id #{patient_id}"
                    expected_category_code = splitted_category.length() == 2 ? splitted_category.last() : splitted_category.first()
                    result_category = resource.entry.first().resource.category.first().coding.first()
                    result_category_code = result_category.code
                    assert result_category_code == expected_category_code, "Result category code #{result_category_code} should be equal to #{expected_category_code}"
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
                    splitted_clinical_status = clinical_status.split('|')

                    fhir_search(:condition, params: { patient: patient_id, "clinical-status": clinical_status })

                    assert_response_status(200)
                    assert_resource_type(:bundle)
                    assert resource.entry.length() > 0
                    result_patient_id = resource.entry.first().resource.subject.reference.split('/').last()
                    assert result_patient_id == patient_id,
                        "Requested resource with id #{result_patient_id}, received resource with id #{patient_id}"
                    expected_clinical_status = splitted_clinical_status.length() == 2 ? splitted_clinical_status.last() : splitted_clinical_status.first()
                    result_clinical_status_code = resource.entry.first().resource.clinicalStatus.coding.first().code
                    assert result_clinical_status_code == expected_clinical_status, "Result category code #{result_clinical_status_code} should be equal to #{expected_clinical_status}"
                end
            end
        end

        test do
            # TODO Add assert for category and clinical status
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
                    assert resource.entry.length() > 0
                    result_patient_id = resource.entry.first().resource.subject.reference.split('/').last()
                    assert result_patient_id == patient_id,
                        "Requested resource with id #{result_patient_id}, received resource with id #{patient_id}"
                end
            end
        end

        test do
            # TODO Add assert for code
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
                    assert resource.entry.length() > 0
                    result_patient_id = resource.entry.first().resource.subject.reference.split('/').last()
                    assert result_patient_id == patient_id,
                        "Requested resource with id #{result_patient_id}, received resource with id #{patient_id}"
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
                assert resource.entry.length() > 0
                result_patient_id = resource.entry.first().resource.subject.reference.split('/').last()
                assert result_patient_id == patient_id,
                    "Requested resource with id #{result_patient_id}, received resource with id #{patient_id}"
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
                fhir_search(:condition, params: { "patient.identifier": patient_identifier,  })
                assert_response_status(200)
                assert_resource_type(:bundle)
                assert resource.entry.length() > 0
            end
        end
    end
end
