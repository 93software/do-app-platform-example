import Config

config :my_app, MyAppWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT") |> String.to_integer()],
  url: [scheme: "https", host: System.fetch_env!("HOST"), port: 443],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")
  ]

config :my_app, MyApp.Repo,
  url: System.fetch_env!("DB_DATABASE_URL"),
  maintenance_database: System.fetch_env!("DB_DATABASE"),
  ssl: true,
  pool_size: 10
