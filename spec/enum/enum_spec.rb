require 'spec_helper'

describe ActiveHash::Base, "enum" do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class Borough < ActiveYaml::Base
      include ActiveHash::Enum
      fields :name, :county, :population
      enum_accessor :name
    end

    class Neighborhood < ActiveHash::Base
      include ActiveHash::Enum
      fields :name, :county
      enum_accessor :name, :county

      self.data = [
        {:name => "Queen Ann", :county => "King"}
      ]
    end
  end

  after do
    Object.send(:remove_const, :Borough)
    Object.send(:remove_const, :Neighborhood)
  end

  describe "#enum_accessor" do
    it "can use a custom method" do
      expect(Borough::BROOKLYN).to eq(Borough.find_by_name("Brooklyn"))
    end

    it "sets the field used for accessing records by constants" do
      expect(Neighborhood::QUEEN_ANN_KING).to eq(Neighborhood.find_by_name("Queen Ann"))
    end

    it "ensures that values stored in the field specified are unique" do
      expect do
        Class.new(ActiveHash::Base) do
          include ActiveHash::Enum
          self.data = [
            {:name => 'Woodford Reserve'},
            {:name => 'Bulliet Bourbon'},
            {:name => 'Woodford Reserve'}
          ]
          enum_accessor :name
        end
      end.to raise_error(ActiveHash::Enum::DuplicateEnumAccessor)
    end

    it "can use enum accessor constant with same name as top-level constant" do
      expect do
        Class.new(ActiveHash::Base) do
          include ActiveHash::Enum
          self.data = [
            {:type => 'JSON'},
            {:type => 'YAML'},
            {:type => 'XML'}
          ]
          enum_accessor :type
        end
      end.not_to raise_error
    end

    it "removes non-word characters from values before setting constants" do
      Movie = Class.new(ActiveHash::Base) do
        include ActiveHash::Enum
        self.data = [
          {:name => 'Die Hard 2', :rating => '4.3'},
          {:name => 'The Informant!', :rating => '4.3'},
          {:name => 'In & Out', :rating => '4.3'}
        ]
        enum_accessor :name
      end

      expect(Movie::DIE_HARD_2.name).to eq('Die Hard 2')
      expect(Movie::THE_INFORMANT.name).to eq('The Informant!')
      expect(Movie::IN_OUT.name).to eq('In & Out')
    end

    describe "enum(columns)" do
      it "defines a predicate method for each value in the enum" do
        Article = Class.new(ActiveHash::Base) do
          include ActiveHash::Enum

          self.data = [
            { name: 'Article 1', status: 'draft'},
            { name: 'Article 2', status: 'published'},
            { name: 'Article 3', status: 'archived'}
          ]

          enum_accessor :name

          enum status: [:draft, :published, :archived]
        end

        expect(Article::ARTICLE_1.draft?).to be_truthy
        expect(Article::ARTICLE_1.published?).to be_falsey
        expect(Article::ARTICLE_1.archived?).to be_falsey

        expect(Article::ARTICLE_2.draft?).to be_falsey
        expect(Article::ARTICLE_2.published?).to be_truthy
        expect(Article::ARTICLE_2.archived?).to be_falsey

        expect(Article::ARTICLE_3.draft?).to be_falsey
        expect(Article::ARTICLE_3.published?).to be_falsey
        expect(Article::ARTICLE_3.archived?).to be_truthy
      end

      it "multi type data (ex: string, integer and symbol) enum" do
        NotifyType = Class.new(ActiveHash::Base) do
          include ActiveHash::Enum

          self.data = [
            { name: 'Like', action: 'LIKE'},
            { name: 'Comment', action: 1},
            { name: 'Follow', action: :FOLLOW},
            { name: 'Mention', action: 'MENTION'}
          ]

          enum_accessor :name

          enum action: { like: 'LIKE', comment: 1, follow: :FOLLOW, mention: 'MENTION' }
        end

        expect(NotifyType::LIKE.like?).to be_truthy
        expect(NotifyType::LIKE.comment?).to be_falsey
        expect(NotifyType::LIKE.follow?).to be_falsey
        expect(NotifyType::LIKE.mention?).to be_falsey

        expect(NotifyType::COMMENT.like?).to be_falsey
        expect(NotifyType::COMMENT.comment?).to be_truthy
        expect(NotifyType::COMMENT.follow?).to be_falsey
        expect(NotifyType::COMMENT.mention?).to be_falsey

        expect(NotifyType::FOLLOW.like?).to be_falsey
        expect(NotifyType::FOLLOW.comment?).to be_falsey
        expect(NotifyType::FOLLOW.follow?).to be_truthy
        expect(NotifyType::FOLLOW.mention?).to be_falsey

        expect(NotifyType::MENTION.like?).to be_falsey
        expect(NotifyType::MENTION.comment?).to be_falsey
        expect(NotifyType::MENTION.follow?).to be_falsey
        expect(NotifyType::MENTION.mention?).to be_truthy
      end
    end
  end

  context "ActiveHash with an enum_accessor set" do
    describe "#save" do
      it "resets the constant's value to the updated record" do
        expect(Borough::BROOKLYN.population).to eq(2556598)
        brooklyn = Borough.find_by_name("Brooklyn")
        brooklyn.population = 2556600
        expect(brooklyn.save).to be_truthy
        expect(Borough::BROOKLYN.population).to eq(2556600)
      end
    end

    describe ".create" do
      it "creates constants for new records" do
        bronx = Borough.create!(:name => "Bronx")
        expect(Borough::BRONX).to eq(bronx)
      end

      it "doesn't create constants for records missing the enum accessor field" do
        expect(Borough.create(:name => "")).to be_truthy
        expect(Borough.create(:population => 12)).to be_truthy
      end
    end

    describe ".delete_all" do
      it "unsets all constants for deleted records" do
        expect(Borough.const_defined?("STATEN_ISLAND")).to be_truthy
        expect(Borough.delete_all).to be_truthy
        expect(Borough.const_defined?("STATEN_ISLAND")).to be_falsey
      end
    end
  end
end
