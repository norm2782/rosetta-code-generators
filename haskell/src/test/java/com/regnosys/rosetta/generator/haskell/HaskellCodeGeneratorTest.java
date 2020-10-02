package com.regnosys.rosetta.generator.haskell;

import static com.regnosys.rosetta.generators.test.TestHelper.toStringContents;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalToIgnoringWhiteSpace;
import static org.junit.jupiter.api.Assertions.*;

import java.net.URL;
import java.util.Collections;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.google.common.io.Resources;
import com.google.inject.AbstractModule;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.regnosys.rosetta.generators.test.TestHelper;
import com.regnosys.rosetta.rosetta.RosettaModel;

public class HaskellCodeGeneratorTest {

	private HaskellCodeGenerator codeGenerator;

	@BeforeEach
	public void setup() {
		Injector injector = Guice.createInjector(new CodeGenModule());
		codeGenerator = injector.getInstance(HaskellCodeGenerator.class);
	}

	@Test
	void simpleClass() throws Exception {
		TestHelper<HaskellCodeGenerator> helper = new TestHelper<>(codeGenerator);
		URL textModel = Resources.getResource("rosetta/sample.rosetta");
		RosettaModel model = helper.parse(textModel);
		HaskellCodeGenerator generator = helper.getExternalGenerator();
		Map<String, ? extends CharSequence> files = generator.afterGenerate(Collections.singletonList(model));
		assertGenerated(Resources.getResource("sample/Classes.hs"), files);
	}

	private void assertGenerated(URL source, Map<String, ? extends CharSequence> map) {
		assertEquals(6, map.entrySet().size());
		assertTrue(map.containsKey("Org/Isda/Cdm/Classes.hs"));
		assertThat(map.get("Org/Isda/Cdm/Classes.hs").toString(), equalToIgnoringWhiteSpace(toStringContents(source)));
	}

	class CodeGenModule extends AbstractModule {

		@Override
		protected void configure() {
		}

	}
}
