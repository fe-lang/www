/**
 * Remark plugin to strip //<hide> ... //</hide> (and legacy <hide> ... </hide>) sections
 * from Fe code fences in rendered docs. Hidden sections remain in source (and in the
 * type-check extractor) but are removed from display.
 */
export default function remarkHideDirective() {
	return function hideDirectiveTransformer(tree) {
		const stripHiddenSections = (value) => {
			const lines = value.split('\n');
			const output = [];
			let hiding = false;
			const startRe = /^\s*(?:\/\/\s*)?<hide>\s*$/;
			const endRe = /^\s*(?:\/\/\s*)?<\/hide>\s*$/;

			for (const line of lines) {
				if (hiding) {
					if (endRe.test(line)) {
						hiding = false;
					}
					continue;
				}

				if (startRe.test(line)) {
					hiding = true;
					continue;
				}

				output.push(line);
			}

			return output.join('\n');
		};

		const walk = (node, fn) => {
			fn(node);
			if (node.children && Array.isArray(node.children)) {
				for (const child of node.children) {
					walk(child, fn);
				}
			}
		};

		walk(tree, (node) => {
			if (node.type === 'code' && typeof node.lang === 'string' && node.lang.startsWith('fe')) {
				node.value = stripHiddenSections(node.value);
			}
		});
	};
}
