<mk-user-preview>
	<a class="avatar-anchor" href={ CONFIG.url + '/' + user.username }>
		<img class="avatar" src={ user.avatar_url + '?thumbnail&size=64' } alt="avatar"/>
	</a>
	<div class="main">
		<header>
			<a class="name" href={ CONFIG.url + '/' + user.username }>{ user.name }</a>
			<span class="username">@{ user.username }</span>
		</header>
		<div class="body">
			<div class="description">{ user.description }</div>
		</div>
	</div>
	<style>
		:scope
			display block
			margin 0
			padding 16px
			font-size 12px

			@media (min-width 350px)
				font-size 14px

			@media (min-width 500px)
				font-size 16px

			&:after
				content ""
				display block
				clear both

			> .avatar-anchor
				display block
				float left
				margin 0 10px 0 0

				@media (min-width 500px)
					margin-right 16px

				> .avatar
					display block
					width 48px
					height 48px
					margin 0
					border-radius 6px
					vertical-align bottom

					@media (min-width 500px)
						width 58px
						height 58px
						border-radius 8px

			> .main
				float left
				width calc(100% - 58px)

				@media (min-width 500px)
					width calc(100% - 74px)

				> header
					@media (min-width 500px)
						margin-bottom 2px

					> .name
						display inline
						margin 0
						padding 0
						color #777
						font-size 1em
						font-weight 700
						text-align left
						text-decoration none

						&:hover
							text-decoration underline

					> .username
						text-align left
						margin 0 0 0 8px
						color #ccc

				> .body

					> .description
						cursor default
						display block
						margin 0
						padding 0
						overflow-wrap break-word
						font-size 1.1em
						color #717171

	</style>
	<script>this.user = this.opts.user</script>
</mk-user-preview>
