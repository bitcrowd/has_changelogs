require 'spec_helper'

describe HasChangelogs do

  describe 'creating a new record' do
    it 'should add a new changelog when a record is created' do
      subject = LogEverythingUser.new(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')
      expect { subject.save }.to change { Changelog.count }.by(1)
    end

    it 'should have the log scope "instance"' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')
      expect(subject.changelogs.last.log_scope).to eq('instance')
    end

    it 'should have the log action "created"' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      expect(subject.changelogs.last.log_action).to eq('created')
    end

    it 'should have the changed attributes of the record created' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      expect(subject.changelogs.last.changed_data).to eq(
        'name'  => [nil, 'Lisa Simpson'],
        'email' => [nil, 'lisa@simpson.com'],
        'uuid'  => [nil, '123ABC']
      )
    end
  end

  describe 'updating a record' do
    it 'should create a changelog of log action updated on every update' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      subject.name = 'Berta Simpson'

      expect { subject.save }.to change { Changelog.count }.by(1)
      expect(subject.changelogs.last.changed_data).to eq(
        'name' => ['Lisa Simpson', 'Berta Simpson']
      )
      expect(subject.changelogs.last.log_action).to eq('updated')
      expect(subject.changelogs.last.log_scope).to eq('instance')
    end

    it 'should create a changelog of log action when updating to nil' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      subject.name = nil

      expect { subject.save }.to change { Changelog.count }.by(1)
      expect(subject.changelogs.last.changed_data).to eq(
        'name' => ['Lisa Simpson', nil]
      )

      expect(subject.changelogs.last.log_action).to eq('updated')
      expect(subject.changelogs.last.log_scope).to eq('instance')
    end

    it 'should not create a changelog if nothing is changed by the update' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      expect { subject.save }.to_not change { Changelog.count }
    end

    it 'should not create a changelog if the change is not noted' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC'
      )

      subject.created_at = 1.day.ago
      expect { subject.save }.to_not change { Changelog.count }
    end
  end

  describe 'destroying a record' do
    it 'should create a changelog of log action destroyed
          when a record is deleted' do
      subject = LogEverythingUser.create(
        name: 'Lisa Simpson',
        email: 'lisa@simpson.com',
        uuid: '123ABC')

      expect { subject.destroy }.to change { Changelog.count }.by(1)

      expect(Changelog.last.changed_data.except('updated_at', 'created_at'))
        .to eq(
          'id'    => subject.id,
          'type'  => 'LogEverythingUser',
          'name'  => 'Lisa Simpson',
          'email' => 'lisa@simpson.com',
          'uuid'  => '123ABC'
        )
      expect(subject.changelogs.last.log_action).to eq('destroyed')
      expect(subject.changelogs.last.log_scope).to eq('instance')
    end
  end

  context 'association changes' do
    describe 'adding a dependend reord' do
      it 'should add a changelog entry on the model if a whatched association
          gains a new record' do
        subject = WithPassportsUser.create(
          name: 'Lisa Simpson',
          email: 'lisa@simpson.com',
          uuid: '123ABC')

        expect do
          subject.passports.create(
            nationality: :de,
            valid_until: Date.parse('2040-12-13')
          )
        end.to change { subject.changelogs.count }.by(1)

        expect(subject.changelogs.last.log_action).to eq('created')

        expect(subject.changelogs.last.log_scope).to eq('association')
        expect(subject.changelogs.last.log_origin).to eq('Passport')

        expect(subject.changelogs.last.changed_data)
          .to eq(
            'nationality' => [nil, 'de'],
            'valid_until' => [nil, '2040-12-13'],
            'user_id'     => [nil, subject.id]
          )
      end
    end

    describe 'changing a dependend reord' do
      it 'should add a changelog entry on the model if a whatched association
          changes a record' do
        subject = WithPassportsUser.create(
          name: 'Lisa Simpson',
          email: 'lisa@simpson.com',
          uuid: '123ABC')

        passport = subject.passports.create(
          nationality: :de,
          valid_until: Date.parse('2040-12-13')
        )

        passport.valid_until = Date.parse('2050-12-13')
        expect { passport.save }.to change { subject.changelogs.count }.by(1)

        expect(subject.changelogs.last.log_action).to eq('updated')

        expect(subject.changelogs.last.log_scope).to eq('association')
        expect(subject.changelogs.last.log_origin).to eq('Passport')

        expect(subject.changelogs.last.changed_data)
          .to eq(
            'valid_until' => ['2040-12-13', '2050-12-13']
          )
      end
    end

    describe 'destroying a dependend reord' do
      it 'should add a changelog entry on the model if a whatched association
          changes a record' do
        subject = WithPassportsUser.create(
          name: 'Lisa Simpson',
          email: 'lisa@simpson.com',
          uuid: '123ABC')

        passport = subject.passports.create(
          nationality: :de,
          valid_until: Date.parse('2040-12-13')
        )

        expect { passport.destroy }.to change { subject.changelogs.count }.by(1)
        expect(subject.changelogs.last.log_action).to eq('destroyed')
        expect(subject.changelogs.last.log_scope).to eq('association')
        expect(subject.changelogs.last.log_origin).to eq('Passport')
        expect(
          Changelog.last.changed_data.except(
            'updated_at',
            'created_at'))
          .to eq(
            'id'          => passport.id,
            'nationality' => 'de',
            'user_id'     => subject.id,
            'valid_until' => '2040-12-13')
      end
    end
  end

  describe 'log metadata' do
    context 'model has metadata method defined' do
      it 'should log metadata' do
        subject = WithMetadataUser.create(
          name: 'Lisa Simpson',
          email: 'lisa@simpson.com',
          uuid: '123ABC')
        expect(subject.log_metadata).to eq({"hello"=>"world"})
      end
    end

    context 'model has default metadata method' do
      it 'should log metadata' do
        subject = LogEverythingUser.create(
          name: 'Lisa Simpson',
          email: 'lisa@simpson.com',
          uuid: '123ABC')
        expect(subject.log_metadata).to eq({})
      end
    end
  end
end
