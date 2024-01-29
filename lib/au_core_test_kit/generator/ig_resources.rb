module AUCoreTestKit
  class Generator
    class IGResources
      def add(resource)
        resources_by_type[resource.resourceType] << resource
      end

      def capability_statement(mode = 'server')
        resources_by_type['CapabilityStatement'].find do |capability_statement_resource|
          capability_statement_resource.rest.any? { |r| r.mode == mode }
        end
      end

      def ig
        resources_by_type['ImplementationGuide'].first
      end

      def inspect
        'IGResources'
      end

      def profile_by_url(url)
        resources_by_type['StructureDefinition'].find { |profile| profile.url == url }
      end

      def resource_for_profile(url)
        resources_by_type['StructureDefinition'].find { |profile| profile.url == url }.type
      end

      def value_set_by_url(url)
        resources_by_type['ValueSet'].find { |profile| profile.url == url }
      end

      def code_system_by_url(url)
        resources_by_type['CodeSystem'].find { |system| system.url == url }
      end

      def search_param_by_id(id_to_search)
        resources_by_type['SearchParameter']
          .find { |param| param.id == id_to_search }
      end

      def search_param_by_resource_and_code(resource, code)
        search_params = resources_by_type['SearchParameter']
          .select { |param| param.base.include?(resource) && param.code == code}

        if search_params.length > 1
          search_params.find do |param|
            param.jurisdiction.any? do |codeable_concept|
              codeable_concept.coding.any? do |coding|
                coding.system == "urn:iso:std:iso:3166" && coding.code == "AU"
              end
            end
          end
        else
          search_params.first
        end
      end

      def search_param_by_resource_and_name(resource, name)
        # remove '_' from search parameter name, such as _id or _tag
        normalized_name = normalized_name = name.to_s.delete_prefix('_')
        search_param_by_resource_and_code(resource, normalized_name)
      end

      private

      def resources_by_type
        @resources_by_type ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end
  end
end
