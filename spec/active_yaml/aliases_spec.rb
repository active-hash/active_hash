require 'spec_helper'

describe ActiveYaml::Aliases do

  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class ArrayProduct < ActiveYaml::Base
      include ActiveYaml::Aliases
    end

    class KeyProduct < ActiveYaml::Base
      include ActiveYaml::Aliases
    end
  end

  after do
    Object.send :remove_const, :ArrayProduct
    Object.send :remove_const, :KeyProduct
  end

  context 'using yaml arrays' do
    let(:model) { ArrayProduct }

    describe '.all' do
      specify { expect(model.all.length).to eq 4 }
    end

    describe 'aliased attributes' do
      subject { model.where(:name => 'Coke').first.attributes }

      it('sets strings correctly') { expect(subject[:flavor]).to eq('sweet') }
      it('sets floats correctly') { expect(subject[:price]).to eq(1.0) }
    end

    describe 'keys starting with "/"' do
      it 'excludes them' do
        models_including_aliases = model.all.select { |p| p.attributes.keys.include? :'/aliases' }
        expect(models_including_aliases).to be_empty
      end
    end
  end

  context 'with YAML hashes' do
    let(:model) { KeyProduct }

    describe '.all' do
      specify { expect(model.all.length).to eq 4 }
    end

    describe 'aliased attributes' do
      subject { model.where(:name => 'Coke').first.attributes }

      it('sets strings correctly') { expect(subject[:flavor]).to eq('sweet') }
      it('sets floats correctly') { expect(subject[:price]).to eq(1.0) }
    end

    describe 'keys starting with "/"' do
      it 'excludes them' do
        models_including_aliases = model.all.select { |p| p.attributes.keys.include? :'/aliases' }
        expect(models_including_aliases).to be_empty
      end
    end
  end

  describe 'Loading multiple files' do
    let(:model) { MultipleFiles }
    let(:coke) { model.where(:name => 'Coke').first }
    let(:schweppes) { model.where(:name => 'Schweppes').first }

    before do
      class MultipleFiles < ActiveYaml::Base
        include ActiveYaml::Aliases
        use_multiple_files
        set_filenames 'array_products', 'array_products_2'
      end
    end

    after do
      Object.send :remove_const, :MultipleFiles
    end

    it 'returns correct data from both files' do
      expect(coke.flavor).to eq 'sweet'
      expect(schweppes.flavor).to eq 'bitter'
    end
  end
end
