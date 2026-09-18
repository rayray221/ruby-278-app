# frozen_string_literal: true

class CreateWidgets < ActiveRecord::Migration[7.1]
  def change
    create_table :widgets do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
