<mk-authorized-apps-page>
	<mk-ui ref="ui">
		<mk-authorized-apps></mk-authorized-apps>
	</mk-ui>
	<style>
		:scope
			display block
	</style>
	<script>
		const ui = require('../../../scripts/ui-event');

		this.on('mount', () => {
			document.title = 'Misskey | アプリケーション';
			ui.trigger('title', '<i class="fa fa-puzzle-piece"></i>アプリケーション');
		});
	</script>
</mk-authorized-apps-page>
