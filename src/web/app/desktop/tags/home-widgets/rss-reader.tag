<mk-rss-reader-home-widget>
	<p class="title"><i class="fa fa-rss-square"></i>RSS</p>
	<button onclick={ settings } title="設定"><i class="fa fa-cog"></i></button>
	<div class="feed" if={ !initializing }>
		<virtual each={ item in items }><a href={ item.link } target="_blank">{ item.title }</a></virtual>
	</div>
	<p class="initializing" if={ initializing }><i class="fa fa-spinner fa-pulse fa-fw"></i>読み込んでいます
		<mk-ellipsis></mk-ellipsis>
	</p>
	<style>
		:scope
			display block
			background #fff

			> .title
				margin 0
				padding 0 16px
				line-height 42px
				font-size 0.9em
				font-weight bold
				color #888
				box-shadow 0 1px rgba(0, 0, 0, 0.07)

				> i
					margin-right 4px

			> button
				position absolute
				top 0
				right 0
				padding 0
				width 42px
				font-size 0.9em
				line-height 42px
				color #ccc

				&:hover
					color #aaa

				&:active
					color #999

			> .feed
				padding 12px 16px
				font-size 0.9em

				> a
					display block
					padding 4px 0
					color #666
					border-bottom dashed 1px #eee

					&:last-child
						border-bottom none

			> .initializing
				margin 0
				padding 16px
				text-align center
				color #aaa

				> i
					margin-right 4px

	</style>
	<script>
		this.mixin('api');

		this.url = 'http://news.yahoo.co.jp/pickup/rss.xml';
		this.items = [];
		this.initializing = true;

		this.on('mount', () => {
			this.fetch();
			this.clock = setInterval(this.fetch, 60000);
		});

		this.on('unmount', () => {
			clearInterval(this.clock);
		});

		this.fetch = () => {
			this.api('/api:rss', {
				url: this.url
			}).then(feed => {
				this.update({
					initializing: false,
					items: feed.rss.channel.item
				});
			});
		};

		this.settings = () => {
		};
	</script>
</mk-rss-reader-home-widget>
