require_relative '../../../read_test'

module AUCoreTestKit
  module AUCoreV030
    class OrganizationReadTest < Inferno::Test
      include AUCoreTestKit::ReadTest

      title 'Server returns correct Organization resource from Organization read interaction'
      description 'A server SHALL support the Organization read interaction.'

      id :au_core_v030_organization_read_test

      def resource_type
        'Organization'
      end

      def scratch_resources
        scratch[:organization_resources] ||= {}
      end

      run do
        perform_read_test(all_scratch_resources)
      end
    end
  end
end
