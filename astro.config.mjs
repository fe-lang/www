// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://fe-lang.github.io',
	base: '/www/',
	integrations: [
		starlight({
			title: 'The Fe Guide',
			customCss: ['./src/styles/custom.css'],
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/fe-lang/fe' }],
			sidebar: [
				{
					label: 'Part 1: Getting Started',
					items: [
						{ label: 'What is Fe?', slug: 'getting-started/what-is-fe' },
						{ label: 'Installation', slug: 'getting-started/installation' },
						{ label: 'Your First Contract', slug: 'getting-started/first-contract' },
						{ label: 'Key Concepts at a Glance', slug: 'getting-started/key-concepts' },
					],
				},
				{
					label: 'Part 2: Language Foundations',
					items: [
						{ label: 'Primitive Types', slug: 'foundations/primitive-types' },
						{ label: 'Variables & Mutability', slug: 'foundations/variables' },
						{ label: 'Functions', slug: 'foundations/functions' },
						{ label: 'Control Flow', slug: 'foundations/control-flow' },
						{ label: 'Operators & Expressions', slug: 'foundations/operators' },
					],
				},
				{
					label: 'Part 3: Ingots & Package Management',
					items: [
						{ label: 'What are Ingots?', slug: 'ingots/what-are-ingots' },
						{ label: 'Project Structure', slug: 'ingots/project-structure' },
						{ label: 'The Package Manager', slug: 'ingots/package-manager' },
						{ label: 'Dependencies', slug: 'ingots/dependencies' },
						{ label: 'Publishing Ingots', slug: 'ingots/publishing' },
					],
				},
				{
					label: 'Part 4: Compound Types',
					items: [
						{ label: 'Tuples', slug: 'compound-types/tuples' },
						{ label: 'Structs', slug: 'compound-types/structs' },
						{ label: 'Enums', slug: 'compound-types/enums' },
						{ label: 'Maps', slug: 'compound-types/maps' },
					],
				},
				{
					label: 'Part 5: Effects & the uses Clause',
					items: [
						{ label: 'What Are Effects?', slug: 'effects/what-are-effects' },
						{ label: 'Declaring Effects', slug: 'effects/declaring-effects' },
						{ label: 'Mutability in Effects', slug: 'effects/mutability' },
						{ label: 'Effect Propagation', slug: 'effects/propagation' },
						{ label: 'Built-in Effects', slug: 'effects/built-in' },
						{ label: 'Storage as Effects', slug: 'effects/storage' },
						{ label: 'Why Effects Matter', slug: 'effects/why-effects-matter' },
					],
				},
				{
					label: 'Part 6: Messages & Receive Blocks',
					items: [
						{ label: 'Defining Messages', slug: 'messages/defining-messages' },
						{ label: 'Message Fields', slug: 'messages/fields' },
						{ label: 'Selectors', slug: 'messages/selectors' },
						{ label: 'Receive Blocks', slug: 'messages/receive-blocks' },
						{ label: 'Handler Syntax', slug: 'messages/handler-syntax' },
						{ label: 'Multiple Message Types', slug: 'messages/multiple-types' },
						{ label: 'Message Groups as Interfaces', slug: 'messages/interfaces' },
					],
				},
				{
					label: 'Part 7: Contracts',
					items: [
						{ label: 'Contract Declaration', slug: 'contracts/declaration' },
						{ label: 'Contract-Level Effects', slug: 'contracts/effects' },
						{ label: 'Storage Fields', slug: 'contracts/storage' },
						{ label: 'The init Block', slug: 'contracts/init' },
						{ label: 'Receive Blocks in Contracts', slug: 'contracts/receive-blocks' },
						{ label: 'Contract Composition', slug: 'contracts/composition' },
					],
				},
				{
					label: 'Part 8: Structs & Impl Blocks',
					items: [
						{ label: 'Struct Definition', slug: 'structs/definition' },
						{ label: 'Impl Blocks', slug: 'structs/impl-blocks' },
						{ label: 'Associated Functions', slug: 'structs/associated-functions' },
						{ label: 'Storage Structs', slug: 'structs/storage-structs' },
						{ label: 'Helper Structs', slug: 'structs/helper-structs' },
					],
				},
				{
					label: 'Part 9: Traits & Generics',
					items: [
						{ label: 'Trait Definition', slug: 'traits/definition' },
						{ label: 'Implementing Traits', slug: 'traits/implementing' },
						{ label: 'Generic Functions', slug: 'traits/generics' },
						{ label: 'Trait Bounds', slug: 'traits/bounds' },
						{ label: 'Standard Traits', slug: 'traits/standard-traits' },
					],
				},
				{
					label: 'Part 10: Events & Logging',
					items: [
						{ label: 'Event Structs', slug: 'events/event-structs' },
						{ label: 'Emitting Events', slug: 'events/emitting' },
						{ label: 'The Log Effect', slug: 'events/log-effect' },
						{ label: 'ABI Compatibility', slug: 'events/abi' },
					],
				},
				{
					label: 'Part 11: Error Handling',
					items: [
						{ label: 'Assertions', slug: 'errors/assertions' },
						{ label: 'Revert Patterns', slug: 'errors/revert' },
						{ label: 'Option & Result', slug: 'errors/option-result' },
						{ label: 'Error Messages', slug: 'errors/messages' },
					],
				},
				{
					label: 'Part 12: Access Control Patterns',
					items: [
						{ label: 'Role-Based Access', slug: 'access-control/roles' },
						{ label: 'Owner Patterns', slug: 'access-control/owner' },
						{ label: 'Multi-Role Systems', slug: 'access-control/multi-role' },
						{ label: 'Requiring Roles', slug: 'access-control/requiring' },
					],
				},
				{
					label: 'Part 13: Testing Fe Contracts',
					items: [
						{ label: 'Unit Testing', slug: 'testing/unit-testing' },
						{ label: 'Effect Mocking', slug: 'testing/mocking' },
						{ label: 'Integration Testing', slug: 'testing/integration' },
						{ label: 'The fe test Runner', slug: 'testing/runner' },
					],
				},
				{
					label: 'Part 14: Common Patterns & Recipes',
					items: [
						{ label: 'Token Patterns', slug: 'patterns/tokens' },
						{ label: 'Allowance & Approval', slug: 'patterns/allowance' },
						{ label: 'Supply Management', slug: 'patterns/supply' },
						{ label: 'Pausable Contracts', slug: 'patterns/pausable' },
						{ label: 'Upgradability', slug: 'patterns/upgradability' },
					],
				},
				{
					label: 'Part 15: By Example',
					items: [
						{ label: 'Complete ERC20', slug: 'examples/erc20' },
						{ label: 'NFT Contract', slug: 'examples/erc721' },
						{ label: 'Voting Contract', slug: 'examples/voting' },
						{ label: 'Simple DEX', slug: 'examples/dex' },
					],
				},
				{
					label: 'Appendices',
					items: [
						{ label: 'Keyword Reference', slug: 'appendix/keywords' },
						{ label: 'Built-in Types Reference', slug: 'appendix/types' },
						{ label: 'Intrinsics Reference', slug: 'appendix/intrinsics' },
						{ label: 'Selector Calculation', slug: 'appendix/selectors' },
						{ label: 'Fe for Solidity Developers', slug: 'appendix/from-solidity' },
						{ label: 'Fe for Rust Developers', slug: 'appendix/from-rust' },
					],
				},
			],
		}),
	],
});
