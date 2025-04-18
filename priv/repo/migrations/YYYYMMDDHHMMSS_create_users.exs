# priv/repo/migrations/YYYYMMDDHHMMSS_create_users.exs
defmodule Shannie.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string
      add :name, :string
      add :role, :string, default: "employee"
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
