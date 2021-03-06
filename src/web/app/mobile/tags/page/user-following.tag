<mk-user-following-page>
	<mk-ui ref="ui">
		<mk-user-following ref="list" if={ !parent.fetching } user={ parent.user }></mk-user-following>
	</mk-ui>
	<style>
		:scope
			display block
	</style>
	<script>
		import ui from '../../scripts/ui-event';
		import Progress from '../../../common/scripts/loading';

		this.mixin('api');

		this.fetching = true;
		this.user = null;

		this.on('mount', () => {
			Progress.start();

			this.api('users/show', {
				username: this.opts.user
			}).then(user => {
				this.update({
					fetching: false,
					user: user
				});

				document.title = user.name + 'のフォロー | Misskey';
				// TODO: ユーザー名をエスケープ
				ui.trigger('title', '<img src="' + user.avatar_url + '?thumbnail&size=64">' + user.name + 'のフォロー');

				this.refs.ui.refs.list.on('loaded', () => {
					Progress.done();
				});
			});
		});
	</script>
</mk-user-following-page>
