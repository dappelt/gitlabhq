import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import { setNotification, getStorageKey } from '~/whats_new/utils/notification';

describe('~/whats_new/utils/notification', () => {
  useLocalStorageSpy();

  let wrapper;

  const findNotificationEl = () => wrapper.querySelector('.header-help');
  const findNotificationCountEl = () => wrapper.querySelector('.js-whats-new-notification-count');
  const getAppEl = () => wrapper.querySelector('.app');

  beforeEach(() => {
    loadFixtures('static/whats_new_notification.html');
    wrapper = document.querySelector('.whats-new-notification-fixture-root');
  });

  afterEach(() => {
    wrapper.remove();
  });

  describe('setNotification', () => {
    const subject = () => setNotification(getAppEl());

    it("when storage key doesn't exist it adds notifications class", () => {
      const notificationEl = findNotificationEl();

      expect(notificationEl.classList).not.toContain('with-notifications');

      subject();

      expect(findNotificationCountEl()).toExist();
      expect(notificationEl.classList).toContain('with-notifications');
    });

    it('removes class and count element when storage key is true', () => {
      const notificationEl = findNotificationEl();
      notificationEl.classList.add('with-notifications');
      localStorage.setItem('storage-key', 'false');

      expect(findNotificationCountEl()).toExist();

      subject();

      expect(findNotificationCountEl()).not.toExist();
      expect(notificationEl.classList).not.toContain('with-notifications');
    });
  });

  describe('getStorageKey', () => {
    it('retrieves the storage key data attribute from the el', () => {
      expect(getStorageKey(getAppEl())).toBe('storage-key');
    });
  });
});
