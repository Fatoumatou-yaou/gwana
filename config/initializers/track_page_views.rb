require_relative '../../lib/track_page_views_middleware'

Rails.application.config.middleware.use TrackPageViewsMiddleware
