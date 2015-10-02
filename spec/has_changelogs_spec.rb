require 'spec_helper'

describe HasChangelogs do


  it 'has a version number' do
    expect(HasChangelogs::VERSION).not_to be nil
  end

  describe 'options[:only]' do
    subject { OnlyName.create({name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC"}) }

    context 'name has changed' do
      it 'logs changes' do
        subject.name = "Ms L Simpson"
        expect(subject).to receive(:log_changes)
        subject.save
      end
    end

    context 'name has not changed' do
      it 'does not log changes' do
        subject.email = "lsimpson@springfield.com"
        expect(subject).to_not receive(:log_changes)
        subject.save
      end
    end
  end

  describe 'options[:ignore]' do
    subject { IgnoreName.create({name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC"}) }

    context 'only name has changed' do
      it 'does not log changes' do
        subject.name = "Ms L Simpson"
        #allow(subject).to receive(:change_relevant?).and_return(false)
        expect(subject).to_not receive(:log_changes)
        subject.save
      end
    end
  end

  describe "callbacks" do


    it "should run after create o matter if the change is relevant or not" do
      subject =  IgnoreName.new({name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC"})
      allow(subject).to receive(:change_relevant?).and_return(false)
      expect(subject).to receive(:record_created)
      subject.save
    end

    it "should not run after update if change is not relevant" do
      subject =  IgnoreName.create({name: "Lisa Simpson", email: "lisa@simpson.com", uuid: "123ABC"})
      allow(subject).to receive(:change_relevant?).and_return(false)
      expect(subject).to_not receive(:record_updated)
      subject.save
    end

  end

end
