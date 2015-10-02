require 'spec_helper'

describe HasChangelogs do

  it 'has a version number' do
    expect(HasChangelogs::VERSION).not_to be nil
  end

  describe 'options[:only]' do
    subject { OnlyName.create({ name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC" }) }
    context 'name has changed' do
      it 'is relevant' do
        subject.name = "Ms L Simpson"
        expect(subject).to receive(:change_relevant?).and_return(true)
        subject.save
      end
    end

    context 'name has not changed' do
      it 'is not relevant' do
        subject.email = "lsimpson@springfield.com"
        expect(subject).to receive(:change_relevant?).and_return(false)
        subject.save
      end
    end
  end

  describe 'options[:ignore]' do
    subject { IgnoreName.create({ name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC" }) }

    context 'only name has changed' do
      it 'does not log changes' do
        subject.name = "Ms L Simpson"
        expect(subject).to_not receive(:log_changes)
        subject.save
      end
    end
  end

  describe 'options[:if]' do

    context 'condition is true' do
      subject { IfCondition.create({ name: "True Condition" }) }

      it 'is relevant' do
        expect(subject).to receive(:change_relevant?).and_return(true)
        subject.save
      end
    end

    context 'condition is false' do
      subject { IfCondition.create({ name: "Not True Condition" }) }

      it 'is not relevant' do
        expect(subject).to receive(:change_relevant?).and_return(false)
        subject.save
      end
    end
  end

  describe 'options[:unless]' do
    context 'condition is true' do
      subject { UnlessCondition.create({ name: "True Condition" }) }

      it 'is not relevant' do
        expect(subject).to receive(:change_relevant?).and_return(false)
        subject.save
      end
    end

    context 'condition is false' do
      subject { UnlessCondition.create({ name: "Not True Condition" }) }

      it 'is relevant' do
        expect(subject).to receive(:change_relevant?).and_return(true)
        subject.save
      end
    end
  end

  describe 'callbacks' do
    
    context 'change is relevant' do
      subject = User.create({ name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC" })
      before(:each) do
        allow(subject).to receive(:change_relevant?).and_return(true)
      end
      
      it "should run after_create" do
        subject = User.new({ name: "Marge Simpson", email: "marge@simpson.com", uuid: "123ABC" })
        expect(subject).to receive(:record_created)
        subject.save
      end

      it "should run before_update" do
        expect(subject).to receive(:record_updated)
        subject.save
      end

      it "should run after_destroy" do
        expect(subject).to receive(:record_will_be_destroyed)
        subject.destroy
      end
    end

    context 'change is not relevant' do
      subject = User.create({ name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC" })
      before(:each) do
        allow(subject).to receive(:change_relevant?).and_return(false)
      end
      
      it "should run after_create" do
        subject = User.new({ name: "Marge Simpson", email: "marge@simpson.com", uuid: "123ABC" })
        expect(subject).to receive(:record_created)
        subject.save
      end

      it "should not run before_update" do
        expect(subject).to_not receive(:record_updated)
        subject.save
      end

      it "should run after_destroy" do
        expect(subject).to receive(:record_will_be_destroyed)
        subject.destroy
      end
    end
  end
end
