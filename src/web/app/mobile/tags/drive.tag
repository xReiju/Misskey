<mk-drive>
	<nav>
		<p onclick={ goRoot }><i class="fa fa-cloud"></i>ドライブ</p>
		<virtual each={ folder in hierarchyFolders }>
			<span><i class="fa fa-angle-right"></i></span>
			<p onclick={ move }>{ folder.name }</p>
		</virtual>
		<virtual if={ folder != null }>
			<span><i class="fa fa-angle-right"></i></span>
			<p>{ folder.name }</p>
		</virtual>
		<virtual if={ file != null }>
			<span><i class="fa fa-angle-right"></i></span>
			<p>{ file.name }</p>
		</virtual>
	</nav>
	<mk-uploader ref="uploader"></mk-uploader>
	<div class="browser { fetching: fetching }" if={ file == null }>
		<div class="info" if={ info }>
			<p if={ folder == null }>{ (info.usage / info.capacity * 100).toFixed(1) }%使用中</p>
			<p if={ folder != null && (folder.folders_count > 0 || folder.files_count > 0) }>
				<virtual if={ folder.folders_count > 0 }>{ folder.folders_count }フォルダ</virtual>
				<virtual if={ folder.folders_count > 0 && folder.files_count > 0 }>、</virtual>
				<virtual if={ folder.files_count > 0 }>{ folder.files_count }ファイル</virtual>
			</p>
		</div>
		<div class="folders" if={ folders.length > 0 }>
			<virtual each={ folder in folders }>
				<mk-drive-folder folder={ folder }></mk-drive-folder>
			</virtual>
			<p if={ moreFolders }>もっと読み込む</p>
		</div>
		<div class="files" if={ files.length > 0 }>
			<virtual each={ file in files }>
				<mk-drive-file file={ file }></mk-drive-file>
			</virtual>
			<button class="more" if={ moreFiles } onclick={ fetchMoreFiles }>
				{ fetchingMoreFiles ? '読み込み中' : 'もっと読み込む' }
			</button>
		</div>
		<div class="empty" if={ files.length == 0 && folders.length == 0 && !fetching }>
			<p if={ !folder == null }>ドライブには何もありません。</p>
			<p if={ folder != null }>このフォルダーは空です</p>
		</div>
	</div>
	<div class="fetching" if={ fetching && file == null && files.length == 0 && folders.length == 0 }>
		<div class="spinner">
			<div class="dot1"></div>
			<div class="dot2"></div>
		</div>
	</div>
	<input ref="file" type="file" multiple="multiple" onchange={ changeLocalFile }/>
	<mk-drive-file-viewer if={ file != null } file={ file }></mk-drive-file-viewer>
	<style>
		:scope
			display block
			background #fff

			&[data-is-naked]
				> nav
					top 48px

			> nav
				display block
				position sticky
				position -webkit-sticky
				top 0
				z-index 1
				width 100%
				padding 10px 12px
				overflow auto
				white-space nowrap
				font-size 0.9em
				color rgba(0, 0, 0, 0.67)
				-webkit-backdrop-filter blur(12px)
				backdrop-filter blur(12px)
				background-color rgba(#fff, 0.75)
				border-bottom solid 1px rgba(0, 0, 0, 0.13)

				> p
					display inline
					margin 0
					padding 0

					&:last-child
						font-weight bold

					> i
						margin-right 4px

				> span
					margin 0 8px
					opacity 0.5

			> .browser
				&.fetching
					opacity 0.5

				> .info
					border-bottom solid 1px #eee

					&:empty
						display none

					> p
						display block
						max-width 500px
						margin 0 auto
						padding 4px 16px
						font-size 10px
						color #777

				> .folders
					> mk-drive-folder
						border-bottom solid 1px #eee

				> .files
					> mk-drive-file
						border-bottom solid 1px #eee

					> .more
						display block
						width 100%
						padding 16px
						font-size 16px
						color #555

				> .empty
					padding 16px
					text-align center
					color #999
					pointer-events none

					> p
						margin 0

			> .fetching
				.spinner
					margin 100px auto
					width 40px
					height 40px
					text-align center

					animation sk-rotate 2.0s infinite linear

				.dot1, .dot2
					width 60%
					height 60%
					display inline-block
					position absolute
					top 0
					background rgba(0, 0, 0, 0.2)
					border-radius 100%

					animation sk-bounce 2.0s infinite ease-in-out

				.dot2
					top auto
					bottom 0
					animation-delay -1.0s

				@keyframes sk-rotate { 100% { transform: rotate(360deg); }}

				@keyframes sk-bounce {
					0%, 100% {
						transform: scale(0.0);
					} 50% {
						transform: scale(1.0);
					}
				}

			> [ref='file']
				display none

	</style>
	<script>
		this.mixin('i');
		this.mixin('api');
		this.mixin('stream');

		this.files = [];
		this.folders = [];
		this.hierarchyFolders = [];
		this.selectedFiles = [];

		// 現在の階層(フォルダ)
		// * null でルートを表す
		this.folder = null;

		this.file = null;

		this.isFileSelectMode = this.opts.selectFile;
		this.multiple =this.opts.multiple;

		this.on('mount', () => {
			this.stream.on('drive_file_created', this.onStreamDriveFileCreated);
			this.stream.on('drive_file_updated', this.onStreamDriveFileUpdated);
			this.stream.on('drive_folder_created', this.onStreamDriveFolderCreated);
			this.stream.on('drive_folder_updated', this.onStreamDriveFolderUpdated);

			// Riotのバグでnullを渡しても""になる
			// https://github.com/riot/riot/issues/2080
			//if (this.opts.folder)
			//if (this.opts.file)
			if (this.opts.folder && this.opts.folder != '') {
				this.cd(this.opts.folder, true);
			} else if (this.opts.file && this.opts.file != '') {
				this.cf(this.opts.file, true);
			} else {
				this.fetch();
			}
		});

		this.on('unmount', () => {
			this.stream.off('drive_file_created', this.onStreamDriveFileCreated);
			this.stream.off('drive_file_updated', this.onStreamDriveFileUpdated);
			this.stream.off('drive_folder_created', this.onStreamDriveFolderCreated);
			this.stream.off('drive_folder_updated', this.onStreamDriveFolderUpdated);
		});

		this.onStreamDriveFileCreated = file => {
			this.addFile(file, true);
		};

		this.onStreamDriveFileUpdated = file => {
			const current = this.folder ? this.folder.id : null;
			if (current != file.folder_id) {
				this.removeFile(file);
			} else {
				this.addFile(file, true);
			}
		};

		this.onStreamDriveFolderCreated = folder => {
			this.addFolder(folder, true);
		};

		this.onStreamDriveFolderUpdated = folder => {
			const current = this.folder ? this.folder.id : null;
			if (current != folder.parent_id) {
				this.removeFolder(folder);
			} else {
				this.addFolder(folder, true);
			}
		};

		this.move = ev => {
			this.cd(ev.item.folder);
		};

		this.cd = (target, silent = false) => {
			this.file = null;

			if (target == null) {
				this.goRoot();
				return;
			} else if (typeof target == 'object') target = target.id;

			this.update({
				fetching: true
			});

			this.api('drive/folders/show', {
				folder_id: target
			}).then(folder => {
				this.folder = folder;
				this.hierarchyFolders = [];

				if (folder.parent) dive(folder.parent);

				this.update();
				this.trigger('open-folder', this.folder, silent);
				this.fetch();
			});
		};

		this.addFolder = (folder, unshift = false) => {
			const current = this.folder ? this.folder.id : null;
			// 追加しようとしているフォルダが、今居る階層とは違う階層のものだったら中断
			if (current != folder.parent_id) return;

			// 追加しようとしているフォルダを既に所有してたら中断
			if (this.folders.some(f => f.id == folder.id)) return;

			if (unshift) {
				this.folders.unshift(folder);
			} else {
				this.folders.push(folder);
			}

			this.update();
		};

		this.addFile = (file, unshift = false) => {
			const current = this.folder ? this.folder.id : null;
			// 追加しようとしているファイルが、今居る階層とは違う階層のものだったら中断
			if (current != file.folder_id) return;

			if (this.files.some(f => f.id == file.id)) {
				const exist = this.files.map(f => f.id).indexOf(file.id);
				this.files[exist] = file;
				this.update();
				return;
			}

			if (unshift) {
				this.files.unshift(file);
			} else {
				this.files.push(file);
			}

			this.update();
		};

		this.removeFolder = folder => {
			if (typeof folder == 'object') folder = folder.id;
			this.folders = this.folders.filter(f => f.id != folder);
			this.update();
		};

		this.removeFile = file => {
			if (typeof file == 'object') file = file.id;
			this.files = this.files.filter(f => f.id != file);
			this.update();
		};

		this.appendFile = file => this.addFile(file);
		this.appendFolder = file => this.addFolder(file);
		this.prependFile = file => this.addFile(file, true);
		this.prependFolder = file => this.addFolder(file, true);

		this.goRoot = () => {
			if (this.folder || this.file) {
				this.update({
					file: null,
					folder: null,
					hierarchyFolders: []
				});
				this.trigger('move-root');
				this.fetch();
			}
		};

		this.fetch = () => {
			this.update({
				folders: [],
				files: [],
				moreFolders: false,
				moreFiles: false,
				fetching: true
			});

			this.trigger('begin-fetch');

			let fetchedFolders = null;
			let fetchedFiles = null;

			const foldersMax = 20;
			const filesMax = 20;

			// フォルダ一覧取得
			this.api('drive/folders', {
				folder_id: this.folder ? this.folder.id : null,
				limit: foldersMax + 1
			}).then(folders => {
				if (folders.length == foldersMax + 1) {
					this.moreFolders = true;
					folders.pop();
				}
				fetchedFolders = folders;
				complete();
			});

			// ファイル一覧取得
			this.api('drive/files', {
				folder_id: this.folder ? this.folder.id : null,
				limit: filesMax + 1
			}).then(files => {
				if (files.length == filesMax + 1) {
					this.moreFiles = true;
					files.pop();
				}
				fetchedFiles = files;
				complete();
			});

			let flag = false;
			const complete = () => {
				if (flag) {
					fetchedFolders.forEach(this.appendFolder);
					fetchedFiles.forEach(this.appendFile);
					this.update({
						fetching: false
					});
					// 一連の読み込みが完了したイベントを発行
					this.trigger('fetched');
				} else {
					flag = true;
					// 一連の読み込みが半分完了したイベントを発行
					this.trigger('fetch-mid');
				}
			};

			if (this.folder == null) {
				// Fetch addtional drive info
				this.api('drive').then(info => {
					this.update({ info });
				});
			}
		};

		this.fetchMoreFiles = () => {
			this.update({
				fetching: true,
				fetchingMoreFiles: true
			});

			const max = 30;

			// ファイル一覧取得
			this.api('drive/files', {
				folder_id: this.folder ? this.folder.id : null,
				limit: max + 1
			}).then(files => {
				if (files.length == max + 1) {
					this.moreFiles = true;
					files.pop();
				} else {
					this.moreFiles = false;
				}
				files.forEach(this.appendFile);
				this.update({
					fetching: false,
					fetchingMoreFiles: false
				});
			});
		};

		this.chooseFile = file => {
			if (this.isFileSelectMode) {
				if (this.selectedFiles.some(f => f.id == file.id)) {
					this.selectedFiles = this.selectedFiles.filter(f => f.id != file.id);
				} else {
					this.selectedFiles.push(file);
				}
				this.update();
				this.trigger('change-selection', this.selectedFiles);
			} else {
				this.cf(file);
			}
		};

		this.cf = (file, silent = false) => {
			if (typeof file == 'object') file = file.id;

			this.update({
				fetching: true
			});

			this.api('drive/files/show', {
				file_id: file
			}).then(file => {
				this.fetching = false;
				this.file = file;
				this.folder = null;
				this.hierarchyFolders = [];

				if (file.folder) dive(file.folder);

				this.update();
				this.trigger('open-file', this.file, silent);
			});
		};

		const dive = folder => {
			this.hierarchyFolders.unshift(folder);
			if (folder.parent) dive(folder.parent);
		};

		this.openContextMenu = () => {
			const fn = window.prompt('何をしますか？(数字を入力してください): <1 → ファイルをアップロード | 2 → ファイルをURLでアップロード | 3 → フォルダ作成 | 4 → このフォルダ名を変更 | 5 → このフォルダを移動 | 6 → このフォルダを削除>');
			if (fn == null || fn == '') return;
			switch (fn) {
				case '1':
					this.refs.file.click();
					break;
				case '2':
					this.urlUpload();
					break;
				case '3':
					this.createFolder();
					break;
				case '4':
					this.renameFolder();
					break;
				case '5':
					this.moveFolder();
					break;
				case '6':
					alert('ごめんなさい！フォルダの削除は未実装です...。');
					break;
			}
		};

		this.createFolder = () => {
			const name = window.prompt('フォルダー名');
			if (name == null || name == '') return;
			this.api('drive/folders/create', {
				name: name,
				parent_id: this.folder ? this.folder.id : undefined
			}).then(folder => {
				this.addFolder(folder, true);
				this.update();
			});
		};

		this.renameFolder = () => {
			if (this.folder == null) {
				alert('現在いる場所はルートで、フォルダではないため名前の変更はできません。名前を変更したいフォルダに移動してからやってください。');
				return;
			}
			const name = window.prompt('フォルダー名', this.folder.name);
			if (name == null || name == '') return;
			this.api('drive/folders/update', {
				name: name,
				folder_id: this.folder.id
			}).then(folder => {
				this.cd(folder);
			});
		};

		this.moveFolder = () => {
			if (this.folder == null) {
				alert('現在いる場所はルートで、フォルダではないため移動はできません。移動したいフォルダに移動してからやってください。');
				return;
			}
			const dialog = riot.mount(document.body.appendChild(document.createElement('mk-drive-folder-selector')))[0];
			dialog.one('selected', folder => {
				this.api('drive/folders/update', {
					parent_id: folder ? folder.id : null,
					folder_id: this.folder.id
				}).then(folder => {
					this.cd(folder);
				});
			});
		};

		this.urlUpload = () => {
			const url = window.prompt('アップロードしたいファイルのURL');
			if (url == null || url == '') return;
			this.api('drive/files/upload_from_url', {
				url: url,
				folder_id: this.folder ? this.folder.id : undefined
			});
			alert('アップロードをリクエストしました。アップロードが完了するまで時間がかかる場合があります。');
		};

		this.changeLocalFile = () => {
			this.refs.file.files.forEach(f => this.refs.uploader.upload(f, this.folder));
		};
	</script>
</mk-drive>
