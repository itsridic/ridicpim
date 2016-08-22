def drop_schemas
  connection = ActiveRecord::Base.connection.raw_connection
  schemas = connection.query(%Q{
    SELECT 'drop schema ' || nspname || ' cascade;'
    from pg_namespace
    where nspname != 'public'
    AND nspname NOT LIKE 'pg_%'
    AND nspname != 'information_schema';
  })
  schemas.each do |query|
    connection.query(query.values.first)
  end
end

def sign_user_in(user, opts={})
  if opts[:subdomain]
    visit new_user_session_url(subdomain: opts[:subdomain])
  else
    visit new_user_session_path
  end
  fill_in 'user[email]', with: user.email
  fill_in 'user[password]', with: (opts[:password] || user.password)
  click_button 'Log in'
end

def set_subdomain(subdomain)
  Capybara.app_host = "http://#{subdomain}.example.com"
end