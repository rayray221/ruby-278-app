# frozen_string_literal: true

module Types
  class QueryType < GraphQL::Schema::Object
    field :health, String, null: false

    def health
      "ok"
    end
  end
end
