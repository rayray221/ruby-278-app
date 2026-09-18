# frozen_string_literal: true

class AppSchema < GraphQL::Schema
  query Types::QueryType
end
