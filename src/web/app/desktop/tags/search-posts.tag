<mk-search-posts>
	<div class="loading" if={ isLoading }>
		<mk-ellipsis-icon></mk-ellipsis-icon>
	</div>
	<p class="empty" if={ isEmpty }><i class="fa fa-search"></i>「{ query }」に関する投稿は見つかりませんでした。</p>
	<mk-timeline ref="timeline"><yield to="footer"><i class="fa fa-moon-o" if={ !parent.moreLoading }></i><i class="fa fa-spinner fa-pulse fa-fw" if={ parent.moreLoading }></i></yield></mk-timeline>
	<style>
		:scope
			display block
			background #fff

			> .loading
				padding 64px 0

			> .empty
				display block
				margin 0 auto
				padding 32px
				max-width 400px
				text-align center
				color #999

				> i
					display block
					margin-bottom 16px
					font-size 3em
					color #ccc

	</style>
	<script>
		this.mixin('api');

		this.query = this.opts.query;
		this.isLoading = true;
		this.isEmpty = false;
		this.moreLoading = false;
		this.page = 0;

		this.on('mount', () => {
			document.addEventListener('keydown', this.onDocumentKeydown);
			window.addEventListener('scroll', this.onScroll);

			this.api('posts/search', {
				query: this.query
			}).then(posts => {
				this.update({
					isLoading: false,
					isEmpty: posts.length == 0
				});
				this.refs.timeline.setPosts(posts);
				this.trigger('loaded');
			});
		});

		this.on('unmount', () => {
			document.removeEventListener('keydown', this.onDocumentKeydown);
			window.removeEventListener('scroll', this.onScroll);
		});

		this.onDocumentKeydown = e => {
			if (e.target.tagName != 'INPUT' && e.target.tagName != 'TEXTAREA') {
				if (e.which == 84) { // t
					this.refs.timeline.focus();
				}
			}
		};

		this.more = () => {
			if (this.moreLoading || this.isLoading || this.timeline.posts.length == 0) return;
			this.update({
				moreLoading: true
			});
			this.api('posts/search', {
				query: this.query,
				page: this.page + 1
			}).then(posts => {
				this.update({
					moreLoading: false,
					page: page + 1
				});
				this.refs.timeline.prependPosts(posts);
			});
		};

		this.onScroll = () => {
			const current = window.scrollY + window.innerHeight;
			if (current > document.body.offsetHeight - 16) this.more();
		};
	</script>
</mk-search-posts>
