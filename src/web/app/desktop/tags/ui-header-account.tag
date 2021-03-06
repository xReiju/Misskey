<mk-ui-header-account>
	<button class="header" data-active={ isOpen.toString() } onclick={ toggle }>
		<span class="username">{ I.username }<i class="fa fa-angle-down" if={ !isOpen }></i><i class="fa fa-angle-up" if={ isOpen }></i></span>
		<img class="avatar" src={ I.avatar_url + '?thumbnail&size=64' } alt="avatar"/>
	</button>
	<div class="menu" if={ isOpen }>
		<ul>
			<li>
				<a href={ '/' + I.username }><i class="fa fa-user"></i>%i18n:desktop.tags.mk-ui-header-account.profile%<i class="fa fa-angle-right"></i></a>
			</li>
			<li onclick={ drive }>
				<p><i class="fa fa-cloud"></i>%i18n:desktop.tags.mk-ui-header-account.drive%<i class="fa fa-angle-right"></i></p>
			</li>
			<li>
				<a href="/i>mentions"><i class="fa fa-at"></i>%i18n:desktop.tags.mk-ui-header-account.mentions%<i class="fa fa-angle-right"></i></a>
			</li>
		</ul>
		<ul>
			<li onclick={ settings }>
				<p><i class="fa fa-cog"></i>%i18n:desktop.tags.mk-ui-header-account.settings%<i class="fa fa-angle-right"></i></p>
			</li>
		</ul>
		<ul>
			<li onclick={ signout }>
				<p><i class="fa fa-power-off"></i>%i18n:desktop.tags.mk-ui-header-account.signout%<i class="fa fa-angle-right"></i></p>
			</li>
		</ul>
	</div>
	<style>
		:scope
			display block
			float left

			> .header
				display block
				margin 0
				padding 0
				color #dbe2e0
				border none
				background transparent
				cursor pointer

				*
					pointer-events none

				&:hover
				&[data-active='true']
					color #fff

					> .avatar
						filter saturate(150%)

				> .username
					display block
					float left
					margin 0 12px 0 16px
					max-width 16em
					line-height 48px
					font-weight bold
					font-family Meiryo, sans-serif
					text-decoration none

					i
						margin-left 8px

				> .avatar
					display block
					float left
					min-width 32px
					max-width 32px
					min-height 32px
					max-height 32px
					margin 8px 8px 8px 0
					border-radius 4px
					transition filter 100ms ease

			> .menu
				display block
				position absolute
				top 56px
				right -2px
				width 230px
				font-size 0.8em
				background #fff
				border-radius 4px
				box-shadow 0 1px 4px rgba(0, 0, 0, 0.25)

				&:before
					content ""
					pointer-events none
					display block
					position absolute
					top -28px
					right 12px
					border-top solid 14px transparent
					border-right solid 14px transparent
					border-bottom solid 14px rgba(0, 0, 0, 0.1)
					border-left solid 14px transparent

				&:after
					content ""
					pointer-events none
					display block
					position absolute
					top -27px
					right 12px
					border-top solid 14px transparent
					border-right solid 14px transparent
					border-bottom solid 14px #fff
					border-left solid 14px transparent

				ul
					display block
					margin 10px 0
					padding 0
					list-style none

					& + ul
						padding-top 10px
						border-top solid 1px #eee

					> li
						display block
						margin 0
						padding 0

						> a
						> p
							display block
							z-index 1
							padding 0 28px
							margin 0
							line-height 40px
							color #868C8C
							cursor pointer

							*
								pointer-events none

							> i:first-of-type
								margin-right 6px

							> i:last-of-type
								display block
								position absolute
								top 0
								right 8px
								z-index 1
								padding 0 20px
								font-size 1.2em
								line-height 40px

							&:hover, &:active
								text-decoration none
								background $theme-color
								color $theme-color-foreground

	</style>
	<script>
		import contains from '../../common/scripts/contains';
		import signout from '../../common/scripts/signout';
		this.signout = signout;

		this.mixin('i');

		this.isOpen = false;

		this.on('before-unmount', () => {
			this.close();
		});

		this.toggle = () => {
			this.isOpen ? this.close() : this.open();
		};

		this.open = () => {
			this.update({
				isOpen: true
			});
			document.querySelectorAll('body *').forEach(el => {
				el.addEventListener('mousedown', this.mousedown);
			});
		};

		this.close = () => {
			this.update({
				isOpen: false
			});
			document.querySelectorAll('body *').forEach(el => {
				el.removeEventListener('mousedown', this.mousedown);
			});
		};

		this.mousedown = e => {
			e.preventDefault();
			if (!contains(this.root, e.target) && this.root != e.target) this.close();
			return false;
		};

		this.drive = () => {
			this.close();
			riot.mount(document.body.appendChild(document.createElement('mk-drive-browser-window')));
		};

		this.settings = () => {
			this.close();
			riot.mount(document.body.appendChild(document.createElement('mk-settings-window')));
		};

	</script>
</mk-ui-header-account>
