require "spec_helper"
require "slack_announcer"

RSpec.describe SlackAnnouncer do
  %w(staging production).each do |environment_name|
    it "annouces a #{environment_name} deploy to slack" do
      expect(HTTP).to receive(:post) do |url, params|
        expect(url).to eq('http://slack.url')
        expect(JSON.parse(params[:body])).to include(
          "username" => "Badger",
          "text" => "<https://github.com/alphagov/application|Application> was just deployed to *#{environment_name}*",
          "channel" => "#2ndline",
        )
      end

      announcer = described_class.new(environment_name, "http://slack.url")
      announcer.announce("application", "Application")
    end
  end

  it "does not announce deploys to other environments" do
    expect(HTTP).not_to receive(:post)

    announcer = described_class.new("integration", "http://slack.url")
    announcer.announce("application", "Application")
  end

  it "logs and swallows announcement errors so that the deployment does not fail" do
    expect(HTTP).to receive(:post).and_raise(StandardError)

    announcer = described_class.new("production", "http://slack.url")
    expect(announcer).to receive(:puts).with(/StandardError/)
    expect { announcer.announce("application", "Application") }.not_to raise_error
  end

  it "can override the Slack channel" do
    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "channel" => "#some_other_channel",
      )
    end

    announcer = described_class.new("production", "http://slack.url")
    announcer.announce("application", "Application", "#some_other_channel")
  end

  it "includes dashboard links when dashboard exists in Grafana production deployments" do
    expected_text = "<https://github.com/alphagov/whitehall|Whitehall> was just deployed to *production*\n" +
      ":chart_with_upwards_trend: Why not check out the <https://grafana.publishing.service.gov.uk/dashboard/file/deployment_whitehall.json|Whitehall deployment dashboard>?"

    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("production", "http://slack.url")
    announcer.announce("whitehall", "Whitehall")
  end

  it "includes dashboard links when dashboard exists in Grafana staging deployments" do
    expected_text = "<https://github.com/alphagov/whitehall|Whitehall> was just deployed to *staging*\n" +
      ":chart_with_upwards_trend: Why not check out the <https://grafana.staging.publishing.service.gov.uk/dashboard/file/deployment_whitehall.json|Whitehall deployment dashboard>?"

    expect(HTTP).to receive(:post) do |_url, params|
      expect(JSON.parse(params[:body])).to include(
        "text" => expected_text,
      )
    end

    announcer = described_class.new("staging", "http://slack.url")
    announcer.announce("whitehall", "Whitehall")
  end
end
