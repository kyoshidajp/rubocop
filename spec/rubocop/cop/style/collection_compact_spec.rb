# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionCompact, :config do
  it 'registers an offense and corrects when using `reject` on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
      array.reject! { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` with block pass arg on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject(&:nil?)
            ^^^^^^^^^^^^^^ Use `compact` instead of `reject(&:nil?)`.
      array.reject!(&:nil?)
            ^^^^^^^^^^^^^^^ Use `compact!` instead of `reject!(&:nil?)`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` on hash to reject nils' do
    expect_offense(<<~RUBY)
      hash.reject { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |k, v| v.nil? }`.
      hash.reject! { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |k, v| v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.compact
      hash.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `select/select!` to reject nils' do
    expect_offense(<<~RUBY)
      array.select { |e| !e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `select { |e| !e.nil? }`.
      hash.select! { |k, v| !v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `select! { |k, v| !v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      hash.compact!
    RUBY
  end

  it 'does not register an offense when using `reject` to not to rejecting nils' do
    expect_no_offenses(<<~RUBY)
      array.reject { |e| e.odd? }
    RUBY
  end

  it 'does not register an offense when using `compact/compact!`' do
    expect_no_offenses(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  context 'when without receiver' do
    it 'does not register an offense and corrects when using `reject` on array to reject nils' do
      expect_no_offenses(<<~RUBY)
        reject { |e| e.nil? }
        reject! { |e| e.nil? }
      RUBY
    end

    it 'does not register an offense and corrects when using `select/select!` to reject nils' do
      expect_no_offenses(<<~RUBY)
        select { |e| !e.nil? }
        select! { |k, v| !v.nil? }
      RUBY
    end
  end

  context 'on lazy' do
    let(:config) do
      RuboCop::Config
        .new(
          'AllCops' => { 'TargetRubyVersion' => target_ruby_version }
        )
    end

    context '= Ruby 2.7', :ruby27 do
      let(:target_ruby_version) { 2.7 }
      it 'does not register an offense when using `reject/reject!`' do
        expect_no_offenses(<<~RUBY)
          array.lazy.reject(&:nil?)
          array.lazy.reject!(&:nil?)
        RUBY
      end
    end

    context '>= Ruby 3.1', :ruby31 do
      let(:target_ruby_version) { 3.1 }
      it 'registers an offense and corrects when using `reject` with block pass arg on array to reject nils' do
        expect_offense(<<~RUBY)
          array.lazy.reject(&:nil?)
                     ^^^^^^^^^^^^^^ Use `compact` instead of `reject(&:nil?)`.
          array.lazy.reject!(&:nil?)
                     ^^^^^^^^^^^^^^^ Use `compact!` instead of `reject!(&:nil?)`.
        RUBY

        expect_correction(<<~RUBY)
          array.lazy.compact
          array.lazy.compact!
        RUBY
      end
    end
  end
end
