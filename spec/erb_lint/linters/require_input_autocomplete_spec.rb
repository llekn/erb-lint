# frozen_string_literal: true

require 'spec_helper'

describe ERBLint::Linters::RequireInputAutocomplete do
  let(:linter_config) { described_class.config_schema.new }

  let(:file_loader) { ERBLint::FileLoader.new('.') }
  let(:linter) { described_class.new(file_loader, linter_config) }
  let(:processed_source) { ERBLint::ProcessedSource.new('file.rb', file) }
  let(:offenses) { linter.offenses }
  let(:corrector) { ERBLint::Corrector.new(processed_source, offenses) }
  let(:corrected_content) { corrector.corrected_content }
  before { linter.run(processed_source) }

  describe 'pure HTML linting' do
    subject { offenses }

    context 'when input type requires autocomplete attribute and it is present' do
      let(:file) { '<input type="email" autocomplete="foo">' }
      it { expect(subject).to(eq([])) }
    end

    context 'when input type does not require autocomplete attribute and it is not present' do
      let(:file) { '<input type="bar">' }
      it { expect(subject).to(eq([])) }
    end

    context 'when input type requires autocomplete attribute and it is not present' do
      let(:file) { '<input type="email">' }
      it do
        expect(subject).to(eq([
          build_offense(1..5,
            "Input tag is missing an autocomplete attribute. If no autocomplete behaviour "\
            "is desired, use the value `off` or `nope`."),
        ]))
      end
    end
  end

  describe 'input field helpers linting' do
    subject { offenses }

    context 'usage of date_field_tag with autocomplete' do
      let(:file) { <<~FILE }
        <br />
        <%= date_field_tag autocomplete: "foo" do %>
        FILE

      it { expect(subject).to(eq([])) }
    end

    context 'usage of text_field_tag with autocomplete' do
      let(:file) { <<~FILE }
        <br />
        <%= text_field_tag autocomplete: "foo" do %>
        FILE

      it { expect(subject).to(eq([])) }
    end

    context 'usage of week_field_tag with autocomplete' do
      let(:file) { <<~FILE }
        <br />
        <%= week_field_tag autocomplete: "foo" do %>
        FILE

      it { expect(subject).to(eq([])) }
    end

    context 'usage of date_field_tag without autocomplete value' do
      let(:file) { <<~FILE }
        <br />
        <%= date_field_tag do %>
        FILE

      it do
        expect(subject).to(eq([
          build_offense(7..30,
            "Input field helper is missing an autocomplete attribute. If no autocomplete behaviour "\
            "is desired, use the value `off` or `nope`."),
        ]))
      end
    end

    context 'usage of text_field_tag without autocomplete value' do
      let(:file) { <<~FILE }
        <br />
        <%= text_field_tag do %>
        FILE

      it do
        expect(subject).to(eq([
          build_offense(7..30,
            "Input field helper is missing an autocomplete attribute. If no autocomplete behaviour "\
            "is desired, use the value `off` or `nope`."),
        ]))
      end
    end

    context 'usage of week_field_tag without autocomplete value' do
      let(:file) { <<~FILE }
        <br />
        <%= week_field_tag do %>
        FILE

      it do
        expect(subject).to(eq([
          build_offense(7..30,
            "Input field helper is missing an autocomplete attribute. If no autocomplete behaviour "\
            "is desired, use the value `off` or `nope`."),
        ]))
      end
    end
  end

  private

  def build_offense(range, message)
    ERBLint::Offense.new(
      linter,
      processed_source.to_source_range(range),
      message
    )
  end
end
