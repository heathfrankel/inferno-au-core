require 'date'

module InfernoTemplate
    module Utils
        def extract_resources_from_bundle(bundle)
            bundle.entry.map { |entr| entr.resource }
        end

        def filter_patients(patients, criteria)
            patients.select do |patient|
                criteria.all? do |key, value|
                    case key
                    when :id
                        patient.id == value
                    when :identifier_system, :identifier_value
                        patient.identifier.any? { |identifier| identifier.send(key.to_s.split('_').last()) == value }
                    when :family_name
                        patient.name.any? { |name| name.family.downcase == value.downcase }
                    when :name
                        patient.name.any? do |name|
                            [name.family, *name.given, *name.prefix, *name.suffix].compact.any? do |name_part|
                                name_part.downcase.include?(value.downcase)
                            end
                        end
                    when :birth_date
                        patient.birthDate == value
                    when :gender
                        patient.gender == value
                    else
                        raise ArgumentError, "Unknown filter key: #{key}"
                    end
                end
            end
        end

        def filter_conditions(conditions, criteria)
            conditions.select do |condition|
                criteria.all? do |key, value|
                    case key
                    when :id
                        condition.id == value
                    when :subject
                        condition.subject.reference.split('/').last == value
                    when :clinicalStatus, :code
                        match_codeable_concept(condition.send(key), value)
                    when :category
                        condition.category.any? { |category_item| match_codeable_concept(category_item, value) }
                    when :onSetDateTimeGE
                        string_to_datetime(condition.onsetDateTime) >= string_to_datetime(value)
                    else
                        raise ArgumentError, "Unknown filter key: #{key}"
                    end
                end
            end
        end

        def match_codeable_concept(codeable_concept, criteria_value)
            criteria_values = criteria_value.split(',')

            criteria_values.any? do |criteria|
                if criteria.include?('|')
                    system, code = criteria.split('|')
                    codeable_concept.coding.any? { |coding| coding.system == system && coding.code == code }
                else
                    codeable_concept.coding.any? { |coding| coding.code == criteria }
                end
            end
        end

        def string_to_datetime(datetime_string)
            if datetime_string.length() == 4
                datetime_string = "#{datetime_string}-01-01T00:00:00Z"
            end

            DateTime.parse(datetime_string)
        end

    end
end