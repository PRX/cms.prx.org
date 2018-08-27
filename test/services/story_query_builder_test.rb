require 'test_helper'

describe StoryQueryBuilder do
  let(:account) { create(:account) }
  let(:token) { StubToken.new(account.id, ['member'], 456) }
  let(:authorization) { Authorization.new(token) }
  let(:unauth_account) { create(:account) }

  it "#to_hash with authorization" do
    dsl = described_class.new(
      params: { from: 1, size: 5, },
      query: 'foo OR Bar',
      fielded_query: { something: '123' },
      authorization: authorization
    )
    dsl.to_hash.must_equal({
      _source: ["id"],
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: '(foo OR Bar) AND (something:(123))',
                default_operator: 'and',
                lenient: true,
                fields: %w( title short_description description ),
              },
            },
          ],
          filter: [
            { terms: { account_id: [account.id] } }
          ],
        },
      },
      sort: [ { published_at: :desc, updated_at: :desc } ],
      size: 5,
      from: 1
    })
  end

  it "#to_hash without authorization" do
    dsl = described_class.new(
      params: { from: 1, size: 5, },
      query: 'foo OR Bar',
      fielded_query: { something: '123' },
    )
    dsl.to_hash.must_equal({
      _source: ["id"],
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: '(foo OR Bar) AND (something:(123))',
                default_operator: 'and',
                lenient: true,
                fields: %w( title short_description description ),
              },
            },
          ],
          filter: [
            { range: { published_at: { lte: 'now' } } },
          ],
        },
      },
      sort: [ { published_at: :desc, updated_at: :desc } ],
      size: 5,
      from: 1
    })
  end

  it "defaults to sane pagination" do
    dsl_hash = described_class.new(
      query: "foo OR Bar",
    ).to_hash
    dsl_hash[:size].must_equal Story::MAX_SEARCH_RESULTS
    dsl_hash[:from].must_equal 0
  end

  it "determines from/size from page param" do
    dsl_hash = described_class.new(
      params: { page: 3 },
      query: "foo OR Bar",
    ).to_hash
    dsl_hash[:size].must_equal Story::MAX_SEARCH_RESULTS
    dsl_hash[:from].must_equal( 2 * Story::MAX_SEARCH_RESULTS )
  end

  describe "parses date ranges" do
    it "when created_at is present" do
      some_time = Time.zone.parse("2016-03-25T02:55:57Z")
      dsl = described_class.new(
        fielded_query: {
          created_at: some_time.to_s,
          created_within: "6 months",
        },
        query: "foo OR Bar",
      )
      dsl.composite_query_string.must_equal(
        "(foo OR Bar) AND (created_at:[#{(some_time.utc - 6.months).iso8601} TO #{some_time.utc.iso8601}])"
      )
    end

    it "when created_at is not present defaults to relative-to-now" do
      Timecop.freeze do
        six_months_ago = (Time.current.utc - 6.months).iso8601
        dsl = described_class.new(
          fielded_query: {
            created_within: "6 months",
          },
          query: "foo OR Bar",
        )
        dsl.composite_query_string.must_equal(
          "(foo OR Bar) AND (created_at:[#{six_months_ago} TO now])"
        )
      end
    end
  end

  it "#structured_query" do
    dsl = described_class.new(
      fielded_query: { something: "123" },
      query: "foo OR Bar",
    )
    dsl.structured_query.must_be_instance_of FieldedSearchQuery
    dsl.structured_query.to_s.must_equal "something:(123)"
  end

  it "#composite_query_string" do
    dsl = described_class.new(
      fielded_query: { something: "123" },
      query: "foo OR Bar",
    )
    dsl.composite_query_string.must_equal "(foo OR Bar) AND (something:(123))"
  end

  it "#humanized_query_string" do
    dsl = described_class.new(
      fielded_query: { something: "123" },
      query: "foo OR Bar",
    )
    dsl.humanized_query_string.must_equal "(foo OR Bar) AND (Something:(123))"
  end
end
