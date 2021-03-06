<mk-messaging-form>
	<textarea ref="text" onkeypress={ onkeypress } onpaste={ onpaste } placeholder="ここにメッセージを入力"></textarea>
	<div class="files"></div>
	<mk-uploader ref="uploader"></mk-uploader>
	<button class="send" onclick={ send } disabled={ sending } title="メッセージを送信">
		<i class="fa fa-paper-plane" if={ !sending }></i><i class="fa fa-spinner fa-spin" if={ sending }></i>
	</button>
	<button class="attach-from-local" type="button" title="PCから画像を添付する">
		<i class="fa fa-upload"></i>
	</button>
	<button class="attach-from-drive" type="button" title="アルバムから画像を添付する">
		<i class="fa fa-folder-open"></i>
	</button>
	<input name="file" type="file" accept="image/*"/>
	<style>
		:scope
			display block

			> textarea
				cursor auto
				display block
				width 100%
				min-width 100%
				max-width 100%
				height 64px
				margin 0
				padding 8px
				font-size 1em
				color #000
				outline none
				border none
				border-top solid 1px #eee
				border-radius 0
				box-shadow none
				background transparent

			> .send
				position absolute
				bottom 0
				right 0
				margin 0
				padding 10px 14px
				line-height 1em
				font-size 1em
				color #aaa
				transition color 0.1s ease

				&:hover
					color $theme-color

				&:active
					color darken($theme-color, 10%)
					transition color 0s ease

			.files
				display block
				margin 0
				padding 0 8px
				list-style none

				&:after
					content ''
					display block
					clear both

				> li
					display block
					float left
					margin 4px
					padding 0
					width 64px
					height 64px
					background-color #eee
					background-repeat no-repeat
					background-position center center
					background-size cover
					cursor move

					&:hover
						> .remove
							display block

					> .remove
						display none
						position absolute
						right -6px
						top -6px
						margin 0
						padding 0
						background transparent
						outline none
						border none
						border-radius 0
						box-shadow none
						cursor pointer

			.attach-from-local
			.attach-from-drive
				margin 0
				padding 10px 14px
				line-height 1em
				font-size 1em
				font-weight normal
				text-decoration none
				color #aaa
				transition color 0.1s ease

				&:hover
					color $theme-color

				&:active
					color darken($theme-color, 10%)
					transition color 0s ease

			input[type=file]
				display none

	</style>
	<script>
		this.mixin('api');

		this.onpaste = e => {
			const data = e.clipboardData;
			const items = data.items;
			for (let i = 0; i < items.length; i++) {
				const item = items[i];
				if (item.kind == 'file') {
					this.upload(item.getAsFile());
				}
			}
		};

		this.onkeypress = e => {
			if ((e.which == 10 || e.which == 13) && e.ctrlKey) {
				this.send();
			}
		};

		this.selectFile = () => {
			this.refs.file.click();
		};

		this.selectFileFromDrive = () => {
			const browser = document.body.appendChild(document.createElement('mk-select-file-from-drive-window'));
			const event = riot.observable();
			riot.mount(browser, {
				multiple: true,
				event: event
			});
			event.one('selected', files => {
				files.forEach(this.addFile);
			});
		};

		this.send = () => {
			this.sending = true;
			this.api('messaging/messages/create', {
				user_id: this.opts.user.id,
				text: this.refs.text.value
			}).then(message => {
				this.clear();
			}).catch(err => {
				console.error(err);
			}).then(() => {
				this.sending = false;
				this.update();
			});
		};

		this.clear = () => {
			this.refs.text.value = '';
			this.files = [];
			this.update();
		};
	</script>
</mk-messaging-form>
