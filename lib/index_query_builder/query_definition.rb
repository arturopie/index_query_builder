module IndexQueryBuilder

  # Provides a DSL to build a query definition
  class QueryDefinition
    attr_reader :arel_filters, :arel_ordering

    def initialize
      @arel_filters = {}
      @arel_ordering = []
    end

    # Specifies how to filter a field
    #
    # @param field_name [Symbol | [Symbol]] database field name (if one element) or
    #        table names to join plus database field name (if an array of more than 1 element)
    # @param predicates [Hash] of the form operator => filter_name. filter_name should match the key in filters hash
    #        that is passed to IndexQueryBuilder.query methods
    #
    # ==== Operators
    #
    # Operators will apply where clauses to query only if the filter_name is present in filters hash.
    #
    # [:equal_to]
    #   Applies 'field_name = filter_value'
    # [:contains]
    #   Applies substring (ILIKE '%filter_value%')
    # [:greater_than_or_equal_to]
    #   Applies 'field_name >= filter_value'
    # [:less_than]
    #   Applies 'field_name < filter_value'
    # [:present_if]
    #   Applies
    #   * 'field_name IS NOT NULL' if filter_value is truthy
    #   * 'field_name IS NULL' if filter_value is falsey
    #
    # === Examples
    #
    #   query.filter_field :received
    #   query.filter_field :reference, contains: :reference
    #   query.filter_field [:vendor, :name], equal_to: :vendor_name
    #   query.filter_field [:receive_order_items, :sku, :code], equal_to: :sku_code
    #   query.filter_field :expected_delivery_at, greater_than_or_equal_to: :from_expected_delivery_at, less_than: :to_expected_delivery_at
    #   query.filter_field :expected_delivery_at, less_than_or_equal_to: :to_expected_delivery_at
    #   query.filter_field :outbound_trailer_id, present_if: :has_trailer
    #
    def filter_field(field_name, predicates={equal_to: field_name})
      predicates.each do |operator, filter|
        @arel_filters[filter] = []

        if operator == :contains
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            arel.where("#{table_name}.#{field} ILIKE ?", "%#{value}%")
          end
        elsif operator == :equal_to
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            arel.where(table_name => {field => value})
          end
        elsif operator == :greater_than_or_equal_to
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            arel.where("#{table_name}.#{field} >= ?", value)
          end
        elsif operator == :less_than
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            arel.where("#{table_name}.#{field} < ?", value)
          end
        elsif operator == :less_than_or_equal_to
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            arel.where("#{table_name}.#{field} <= ?", value)
          end
        elsif operator == :present_if
          @arel_filters[filter] << ->(arel, value) do
            table_name, field = apply_joins(arel, field_name, filter)
            if value
              arel.where("#{table_name}.#{field} IS NOT NULL")
            else
              arel.where("#{table_name}.#{field} IS NULL")
            end
          end
        else
          raise UnknownOperator.new("Unknown operator #{operator}.")
        end
      end
    end

    # Specifies how to order the result.
    # Uses same syntax as Arel#order (http://guides.rubyonrails.org/active_record_querying.html#ordering)
    #
    # === Examples
    #
    # <tt>query.order_by "expected_delivery_at DESC, receive_orders.id DESC"</tt>
    #
    def order_by(*args)
      @arel_ordering << ->(arel) do
        arel.order(*args)
      end
    end

    def filter_names
      arel_filters.keys
    end

    private

    def apply_joins(arel, qualified_field_name, filter)
      # IQB_TODO: refactor this
      if qualified_field_name.is_a?(Array)
        association_hash, field, table_name = transform(qualified_field_name)
        @arel_filters[filter] << ->(arel, _) { arel.joins(association_hash) }
      else
        table_name = arel.table_name
        field = qualified_field_name
      end

      return table_name.to_s.pluralize, field
    end

    def transform(qualified_field_name)
      field = qualified_field_name[-1]
      association_path = qualified_field_name[0..-2]
      table_name = association_path[-1]
      association_hash = association_path[0..-2].reverse.inject(association_path[-1]) { |memo, e| {e => memo} }
      return association_hash, field, table_name
    end
  end
end
