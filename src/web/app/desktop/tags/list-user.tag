<mk-list-user>
	<a class="avatar-anchor" href={ CONFIG.url + '/' + user.username }>
		<img class="avatar" src={ user.avatar_url + '?thumbnail&size=64' } alt="avatar"/>
	</a>
	<div class="main">
		<header>
			<a class="name" href={ CONFIG.url + '/' + user.username }>{ user.name }</a>
			<span class="username">@{ user.username }</span>
		</header>
		<div class="body">
			<p class="followed" if={ user.is_followed }>フォローされています</p>
			<div class="description">{ user.description }</div>
		</div>
	</div>
	<mk-follow-button user={ user }></mk-follow-button>
	<style>
		:scope
			display block
			margin 0
			padding 16px
			font-size 16px

			&:after
				content ""
				display block
				clear both

			> .avatar-anchor
				display block
				float left
				margin 0 16px 0 0

				> .avatar
					display block
					width 58px
					height 58px
					margin 0
					border-radius 8px
					vertical-align bottom

			> .main
				float left
				width calc(100% - 74px)

				> header
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
					> .followed
						display inline-block
						margin 0 0 4px 0
						padding 2px 8px
						vertical-align top
						font-size 10px
						color #71afc7
						background #eefaff
						border-radius 4px

					> .description
						cursor default
						display block
						margin 0
						padding 0
						overflow-wrap break-word
						font-size 1.1em
						color #717171

			> mk-follow-button
				position absolute
				top 16px
				right 16px

	</style>
	<script>this.user = this.opts.user</script>
</mk-list-user>
