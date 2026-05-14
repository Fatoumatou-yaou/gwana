class TrackPageViewsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    # Ne tracer que les requêtes GET avec un statut 200
    if env["REQUEST_METHOD"] == "GET" && status == 200
      begin
        request = ActionDispatch::Request.new(env)
        PageView.create(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          path: request.path,
          referer: request.referer
        )
      rescue => e
        Rails.logger.debug("Error tracking page view: #{e.message}")
      end
    end

    [ status, headers, body ]
  end
end
