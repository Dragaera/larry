Sequel.migration do
  up do
    create_table :whales do
      primary_key :id

      foreign_key :identity_id, :whales, null: true, on_update: :cascade, on_delete: :cascade

      String :name,             null: false, unique: true
      Fixnum :sheet_row_number, null: true,  unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at
    end
  end

  down do
    drop_table :whales
  end
end

