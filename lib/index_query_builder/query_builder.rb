module IndexQueryBuilder
  class QueryBuilder
    def self.apply(base_scope, query_definition, filters)
      new(query_definition, filters).apply(base_scope)
    end

    attr_reader :query_definition, :filters

    def initialize(query_definition, filters)
      @query_definition = query_definition
      @filters = filters
    end

    def apply(base_scope)
      apply_filters(apply_order_by(base_scope))
    end

    private

    def apply_order_by(arel)
      query_definition.arel_ordering.reduce(arel) do |arel, ordering|
        ordering.call(arel)
      end
    end

    def apply_filters(arel)
      filters.reduce(arel) do |arel, (filter_name, filter_value)|
        apply_predicates_for_filter(arel, filter_name, filter_value)
      end
    end

    def apply_predicates_for_filter(arel, filter_name, filter_value)
      arel_predicates(filter_name).reduce(arel) { |arel, predicate| predicate.call(arel, filter_value) }
    end

    def arel_predicates(filter_name)
      query_definition.arel_filters.fetch(filter_name) { [] }
    end
  end
end